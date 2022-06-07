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
const fliperAddress = NODE_ENV["FLIPER_ADDRESS"];
const fliperAbi = NODE_ENV["FLIPER_ABI"];
const stakingAddress = NODE_ENV["STAKING_ADDRESS"];
const stakingAbi = NODE_ENV["STAKING_ABI"];

const provider = new ethers.providers.Web3Provider(web3.currentProvider);
const signer = provider.getSigner();
const fliperPassContract = new ethers.Contract(fliperPassAddress, fliperPassAbi, provider);
const fliperContract = new ethers.Contract(fliperAddress, fliperAbi, provider);
const stakingContract = new ethers.Contract(stakingAddress, stakingAbi, provider);
const stakingWithSigner = stakingContract.connect(signer);
const walletAddress = NODE_ENV["WALLET_ADDRESS"];

let owntokens = [];
let stakedtokens = [];

function fetchErrMsg (err) {
    const errMsg = err.error ? err.error.message : err.message;
    console.log("errMsg", errMsg);
    alert('Error:  ' + errMsg.split(/:(.*)/s)[1]);
    $("#spinner").hide();
}

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
      localStorage.setItem("is_subscribed", false);
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
            localStorage.setItem("is_subscribed", data.is_subscribed);
            location.reload();
        }
    })
}

const subscribe = function(month) {
    $.ajax({
        url: "/subscribe",
        method: "post",
        data: { month: month }
    }).done(function(data) {
        localStorage.setItem("is_subscribed", data.is_subscribed);
        location.href = "/";
    })
}

const checkNft = async function() {
    const url = "/not_permitted?error_code="
    const is_subscribed = localStorage.getItem("is_subscribed");
    if (is_subscribed == 'true' || $(".home").length > 0 || $(".fliperPass").length > 0 || $(".error-page").length) {
        $(".content").fadeIn(1000);
    } else {
        let error_code;
        if (loginAddress) {
            const balance = await fliperPassContract.balanceOf(loginAddress);
            console.log("balance", balance);
            const is_owned_token = await fliperPassContract.isOwnedToken(loginAddress);
            console.log("is_owned_token", is_owned_token);
            if (balance < 1 && !is_owned_token) { error_code = 1}
        } else {
            error_code = 2;
        }

        if (error_code) {
            $.get(url + error_code, function(data) {
                $(".content").html('<h3 class="text-center">' + data.message + '</h3>').fadeIn();
            });
        } else {
            $(".content").fadeIn(1000);
        }
    }
}

const getNfts = async function() {
    if (loginAddress) {
        const tokens = await fliperPassContract.getOwnerTokens(loginAddress);
        console.log("tokens", tokens);
        if (tokens.length > 0) {
            const stakedTokens = tokens.filter((token) => token.isStaked)
            const ownTokens = tokens.filter((token) => !token.isStaked)

            addTokenToBlock("stakedToken", stakedTokens);
            addTokenToBlock("ownToken", ownTokens);
        }
    }
}

const addTokenToBlock = function(t_type, tokens) {
    const imgPath = $(".tokenImg").attr("src");
    $.each(tokens, function(_idx, token) {
        $(`.${t_type}s`).append("<span class='" + t_type + "' data-tokenId='" + token.tokenId + "' ><img width='50' height='50' src=' " + imgPath +  "' /><br/>" + token.tokenId + "</span>")
    })
}

$(document).on('turbolinks:load', function() {
    'use strict';

    $(function() {
        $("#spinner").fadeOut("3000", function() {
            checkNft();
        });

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
                    localStorage.setItem("is_subscribed", false);
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

        $(".subBtn").on("click", async function() {
            const price = ethers.utils.parseEther(String($(this).data("price")));
            const month = $(this).data("month");
            if (loginAddress) {
                let balance = await fliperContract.balanceOf(loginAddress);
                balance = parseFloat(balance);
                console.log("balance", balance);
                if (balance < price) {
                    alert("You don't have enough tokens");
                } else {
                    console.log("subscribe", month);
                    fliperContract.connect(signer).transfer(walletAddress, price)
                    .then(async (tx) => {
                        console.log("tx: ", tx)
                        await tx.wait();
                        subscribe(month);
                        alert("Subscribed successfully!");
                    })
                }
            } else {
                checkMetamaskLogin();
            }
        })

        $(".stakeBtn").on("click", async function() {
            $("#spinner").fadeIn();
            try {
                if (owntokens > 0) {
                    const isApproved = await fliperPassContract.isApprovedForAll(loginAddress, stakingAddress);
                    console.log("isApproved", isApproved);
                    if (isApproved) {
                        stakingWithSigner.staking(owntokens)
                        .then(async (tx) => {
                            console.log("tx: ", tx)
                            await tx.wait();
                            alert("Stake successfully!");
                            location.reload();
                        })
                    } else {
                        fliperPassContract.connect(signer).setApprovalForAll(stakingAddress, true)
                        .then(async (tx) => {
                            console.log("tx: ", tx);
                            await tx.wait();
                            stakingWithSigner.staking(owntokens)
                            .then(async (tx) => {
                                console.log("tx: ", tx)
                                await tx.wait();
                                alert("Stake successfully!");
                                location.reload();
                            })
                        })
                    }
                }
            } catch (err) {
                fetchErrMsg(err);
                location.reload();
            }
        })

        $(".unstakeBtn").on("click", async function() {
            $("#spinner").fadeIn();
            if (stakedtokens > 0) {
                stakingWithSigner.claim(stakedtokens)
                .then(async (tx) => {
                    console.log("tx: ", tx)
                    await tx.wait();

                    alert("Unstake successfully!");
                    location.reload();
                }).catch(err => {
                    console.log("error", err);
                    fetchErrMsg(err);
                    location.reload();
                })
            }
        })

        if ($(".staking").length > 0) {
            getNfts();
        }

        $(document).on("click", ".ownToken", function() {
            $(this).toggleClass("selected");
            const tokenId = $(this).data("tokenid")
            console.log("tokenId", tokenId);
            
            if ($(this).hasClass("selected")) {
                owntokens.push(tokenId);
            } else {
                owntokens = owntokens.filter(function(item) {
                    return item !== tokenId;
                })
            }

            console.log("owntokens", owntokens);
        })

        $(document).on("click", ".stakedToken", function() {
            $(this).toggleClass("selected");
            const tokenId = $(this).data("tokenid");
            console.log("tokenId", tokenId);
            
            if ($(this).hasClass("selected")) {
                stakedtokens.push(tokenId);
            } else {
                stakedtokens = stakedtokens.filter(function(item) {
                    return item !== tokenId;
                })
            }

            console.log("stakedtokens", stakedtokens);
        })
    })
})
