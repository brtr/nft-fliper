require("@rails/ujs").start();
require("turbolinks").start();
require("jquery");
require("chartkick");
require("chart.js");
require("moment");
require('select2');
require("ethers");

require("../stylesheets/application.scss");

import 'bootstrap/dist/css/bootstrap';
import 'bootstrap/dist/js/bootstrap';
import Chart from 'chart.js/auto';
import 'chartjs-adapter-moment';
import moment from 'moment';
import 'select2';
import 'select2/dist/css/select2.css';
import { ethers } from 'ethers';

global.Chart = Chart;
global.moment = moment

window.jQuery = $;
window.$ = $;

let loginAddress = localStorage.getItem("loginAddress");
const fliperPassAddress = NODE_ENV["FLIPER_PASS_ADDRESS"];
const fliperPassAbi = NODE_ENV["FLIPER_PASS_ABI"];

const provider = new ethers.providers.Web3Provider(web3.currentProvider);
const fliperPassContract = new ethers.Contract(fliperPassAddress, fliperPassAbi, provider);

function replaceChar(origString, firstIdx, lastIdx, replaceChar) {
    let firstPart = origString.substr(0, firstIdx);
    let lastPart = origString.substr(lastIdx);

    let newString = firstPart + replaceChar + lastPart;
    return newString;
}

const checkMetamaskLogin = async function() {
  $("#spinner").removeClass("hide");
  const accounts = await ethereum.request({ method: 'eth_requestAccounts' });
  changeAddress(accounts);
  $("#spinner").addClass("hide");
}

function changeAddress(accounts) {
  if (accounts.length > 0) {
      localStorage.setItem("loginAddress", accounts[0]);
      loginAddress = accounts[0];
      login();
  } else {
      localStorage.removeItem("loginAddress");
      loginAddress = null;
      toggleAddress();
  }
}

const toggleAddress = function() {
    if(loginAddress) {
        $("#login_address").text(replaceChar(loginAddress, 6, -4, "..."));
        $(".loginBtns .navbar-tool").removeClass("hide");
        $(".loginBtns .connect-btn").addClass("hide");
        $(".actions").removeClass("hide");
    } else {
        $(".actions").addClass("hide");
        $(".loginBtns .navbar-tool").addClass("hide");
        $(".loginBtns .connect-btn").removeClass("hide");
    }
}

const login = function() {
  $.ajax({
      url: "/login",
      method: "post",
      data: { address: loginAddress }
  }).done(function(data) {
      if (data.success) {
          location.reload();
      }
  })
}

const checkNft = async function() {
    if ($(".home").length < 1 && $(".fliperPass").length < 1 && $(".error-page").length < 1) {
        if (loginAddress) {
            const balance = await fliperPassContract.balanceOf(loginAddress);
            console.log("balance", balance);
            if (balance < 1) {
                location.href = "/not_permitted?error_code=1";
            }
        } else {
            location.href = "/not_permitted?error_code=2";
        }
    }
}

$(document).on('turbolinks:load', function() {
    'use strict';
    checkNft();

    $(function() {
        $('[data-bs-toggle="tooltip"]').tooltip({html: true});

        $(".period_targets input").on("click", function() {
            this.form.submit();
        })

        toggleAddress();

        $("#loginBtn").on("click", function(e){
            e.preventDefault();
            checkMetamaskLogin();
        });

        $("#logoutBtn").on("click", function(e){
            $("#spinner").removeClass("hide");
            e.preventDefault();
            localStorage.removeItem("loginAddress");
    
            $.ajax({
                url: "/logout",
                method: "post"
            }).done(function(data) {
                if (data.success) {
                    location.reload();
                }
            })
        });

        $(".synBtn").on("click", function(){
            $("#spinner").removeClass("hide");
        })

        $(".sidebar-toggle").on("click", function(){
            $("#sidebar").toggleClass("collapsed");
        })

        $(".js-settings-toggle").on("click", function() {
            $(".js-settings").toggleClass("open");
        })

        if ($("#flip_records").length > 0) {
            setInterval(function () {
                $.get('/nft_flip_records/check_new_records', function(data){
                    const last_id = data.last_id;
                    if(last_id > 0 ){
                        const change = last_id - parseInt($("#flip_records").data("last-id"))
                        if (change > 0) {
                            $("#loadNewBtn").removeClass("hide")
                        }
                    }
                })
            }, 600000);
        }

        $("#loadNewBtn").on("click", function() {
            var url = new URL(window.location.href);
            var search_params = url.searchParams;
            search_params.set('id', $("#flip_records").data("last-id"));
            var new_url = "/nft_flip_records/get_new_records?" + search_params.toString();
            $(this).attr("href", new_url);
            $(this).addClass("hide");
        })

        $(".loadMoreBtn").on("click", function() {
            const source = $(this).data("source");
            const page = $(`#${source}_current_page`).val();
            var url = new URL(window.location.href);
            var search_params = url.searchParams;
            search_params.set(`${source}_page`, (parseInt(page) + 1));
            var new_url = window.location.pathname + "?" + search_params.toString();
            $(this).attr("href", new_url);
        })

        if ($("#slug").length > 0) {
            setInterval(function () {
                const url = "/nft_flip_records/refresh_listings?slug=" + $("#slug").val();
                $.ajax({
                    type: "GET",
                    dataType: "script",
                    url: url
                })
            }, 60000);
        }

        if($('.select2-container').length < 1) {
            $('.js-data-example-ajax').select2({
                width: "200px",
                ajax: {
                    url: '/nft_flip_records/search_collection',
                    dataType: 'json',
                    processResults: function (data) {
                        return {
                            results: data
                        };
                    },
                    delay: 250
                },
                placeholder: "Searching...",
                minimumInputLength: 1
            });
        }

        $('.js-data-example-ajax').on("select2:select", function(e) {
            var data = e.params.data;
            window.location = "/nft_flip_records/nft_analytics?slug=" + data.text;
        })
    })
})
