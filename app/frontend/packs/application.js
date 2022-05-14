require("@rails/ujs").start();
require("turbolinks").start();
require("jquery");
require("chartkick");
require("chart.js");
require("moment");
require("../stylesheets/application.scss");

import 'bootstrap/dist/css/bootstrap';
import 'bootstrap/dist/js/bootstrap';
import Chart from 'chart.js/auto';
import 'chartjs-adapter-moment';

global.Chart = Chart;

let loginAddress = localStorage.getItem("loginAddress");

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

$(document).on('turbolinks:load', function() {
    'use strict';

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

        setInterval(function () {
            $.get('/nft_flip_records/check_new_records', function(data){
                const last_id = data.result;
                if(last_id > 0 ){
                    const change = last_id - parseInt($("#flip_records").data("last-id"))
                    if (change > 0) {
                        const notice = "<div class='alert alert-success alert-dismissible' role='alert'><button type='button' class='btn-close' data-bs-dismiss='alert' aria-label='Close'></button><div class='alert-message'><strong>有" + change + "条新的Flip数据，请刷新!</strong></div></div>"
                        $(".content").before(notice);
                    }
                }
            })
        }, 600000);
    })
})
