#!/bin/bash
set -e

###
### About
### help.stopcovid19.jp/index.html を生成するスクリプト
###
### Dependency
### - make wget
### - make grep
### - make aggregate
### - make slack-bool-queue
### - make slack-bool-reduce
###
### Usage
### - make publish
###


head=`cat <<EOM
<!DOCTYPE html>
<html lang="ja">
<head>
    <meta charset="utf-8">
    <title>新型コロナウイルス（COVID-19）各自治体の経済支援制度まとめ</title>
    <meta property="og:title" content="新型コロナウイルス（COVID-19）各自治体の経済支援制度まとめ">
    <meta property="og:site_name" content="新型コロナウイルス（COVID-19）各自治体の経済支援制度まとめ">
    <meta name="description" content="全都道府県、全市区町村の新型コロナウイルス（COVID-19）関連の経済支援制度をCode for japanのボランティアたちがまとめたウェブサイトです">
    <meta property="og:description"
          content="全都道府県、全市区町村の新型コロナウイルス（COVID-19）関連の経済支援制度をCode for japanのボランティアたちがまとめたウェブサイトです">
    <meta property="og:type" content="website">
    <meta property="og:url" content="https://help.stopcovid19.jp/">
    <meta property="og:image" content="https://help.stopcovid19.jp/ogimg.png">
    <meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no">
    <style type="text/css">
        .card-content {
            border-radius: 6px;
            box-shadow: rgba(0, 0, 0, 0.04) 0px 1px 18px;
            background-color: rgb(255, 255, 255);
            margin: 1em 0px;
            line-height: 1.8em;
        }

        .card-content:hover {
            box-shadow: rgba(0, 0, 0, 0.12) 0px 1px 18px;
        }

        .card-content > .bottom > .link:hover {
            background-color: rgb(94, 77, 187);
            color: rgb(255, 255, 255);
        }

        .card-content > .top {
            padding: 32px 20px;
        }
        .card-content > .top > .tags {
            display: flex;
            flex-wrap: wrap;
            -webkit-box-align: center;
            align-items: center;
            margin-bottom: 20px;
        }

        .card-content > .top > .tags > .item {
            margin-right: 8px;
            color: rgb(255, 255, 255);
            font-weight: bold;
            background-color: rgb(94, 77, 187);
            padding: 4px 8px;
            border-radius: 4px;
        }

        .card-content > .top > p {
            color: rgb(51, 51, 51);
        }

        .card-content > .top > h2 {
            margin-bottom: 16px;
            color: rgb(51, 51, 51);
            line-height: 1.2em;
            font-size: 1.5em;
            max-height: 8em;
            overflow: hidden;
            position: relative;
        }
        .card-content > .top > h2::after {
            display: block;
            content: '';
            position: absolute;
            width: 100%;
            height: 2em;
            top: 6em;
            background: linear-gradient(rgba(255,255,255,0) 0%, rgba(255,255,255,1) 90%);
        }

        .card-content > .bottom {
            border-top: 1px solid rgb(243, 243, 244);
            padding: 20px;
            display: flex;
            -webkit-box-pack: justify;
            justify-content: space-between;
            flex-wrap: wrap;
            -webkit-box-align: center;
            align-items: center;
        }

        .card-content > .bottom > .link {
            cursor: pointer;
            border-radius: 100px;
            border: 1px solid rgb(94, 77, 187);
            background-color: rgb(255, 255, 255);
            text-align: center;
            padding: 8px 48px;
            font-weight: normal;
            display: block;
            text-decoration: none;
            color: rgb(94, 77, 187);
            margin-left: auto;
            margin-right: 0px;
        }

        .card-content > .bottom > .share-line {
            cursor: pointer;
            margin-left: 0;
            width: 46px;
        }

        .card-content > .bottom > .share-twitter {
            cursor: pointer;
            margin-left: 10px;
            width: 46px;
        }

        .card-content > .bottom > .share-facebook {
            cursor: pointer;
            margin-left: 10px;
            margin-right: auto;
            width: 46px;
        }
        @media (max-width: 450px) {
            .card-content > .top {
                padding: 32px 20px;
            }

            .card-content > .bottom {
                padding: 20px;
            }

            .card-content > .bottom > .link {
                margin-bottom: 8px;
                margin-left: auto;
            }
        }

        .contents {
            background-color: rgb(243, 243, 244);
            min-height: 100vh;
            padding: 16px 0px;
        }

        .contents > div {
            margin: 0px auto 24px;
            max-width: 920px;
        }

        .contents > div span {
            font-weight: bold;
        }

        @media (max-width: 953px) {
            .contents {
                background-color: rgb(243, 243, 244);
                padding: 16px;
            }
        }

        .header {
            background-color: #ac0027;
            padding-bottom: 25px;
            text-align: center;
        }

        .header > .title {
            margin: 0px;
            padding: 30px 0px 20px;
            text-align: center;
            font-size: 45px;
        }

        .header > .search {
            text-align: center;
        }

        .header > h3 > a {
            text-decoration: underline;
            color: white;
            padding: 0 4px;
        }

        .header > h3 > a:hover {
            text-decoration: none;
        }

        .header > .search > form > input#searchbox {
            width: 80vw;
            max-width: 600px;
            height: 50px;
            margin: 0.5em 0.2em 8px 0.5em;
            font-size: 4vw;
            border-radius: 48px;
            border: 2px solid rgb(243, 243, 244);
            line-height: 1.3em;
            padding: 16px 24px;
        }

        @media (min-width: 650px) {
            .header > .search > form > input#searchbox {
                font-size: 26px;
            }
        }

        @media (max-width: 450px) {
            .header > .search > form > input#searchbox {
                width: 80vw;
                font-size: 4.5vw;
            }
        }

        @media (max-width: 450px) {
            .header > .title {
                padding: 30px 0px 20px;
            }

            .header > .title {
                font-size: 9.5vw;
            }

            .header .search > form > input {
                width: 100%;
                margin: 0.5em 0.2em 8px 0.5em;
                font-size: 16px;
                border-radius: 48px;
                border: 2px solid rgb(243, 243, 244);
                line-height: 1.3em;
                padding: 16px 24px;
            }
        }

        .header > .shares {
            display: flex;
            -webkit-box-pack: center;
            justify-content: center;
            -webkit-box-align: center;
            align-items: center;
            flex-wrap: wrap;
            margin: 8px 0px;
        }

        .header > .shares > .share {
            margin: 0 2px;
        }

        *, ::before, ::after {
            box-sizing: border-box;
            list-style: none;
            text-decoration: none;
            margin: 0;
            padding: 0;
        }

        h1, h2, h3, p {
            margin: 0px;
            color: white;
        }

        ul {
            padding: 0px;
            margin: 0px;
            list-style: none;
        }

        a:not([class]) {
            text-decoration-skip-ink: auto;
        }

        input {
            font: inherit;
        }

        p {
            line-height: 170%;
            word-break: break-all;
        }
    </style>
    <script async src="./index.js"></script>
</head>
EOM
`
echo $head

echo "<body>"

header=`cat <<EOM
    <div class="header">
        <h1 class="title">
            新型コロナウイルス（COVID-19）各自治体の経済支援制度まとめ
        </h1>
        <h3>
            全都道府県、全市区町村の新型コロナウイルス（COVID-19）関連の経済支援制度を<a href="https://www.code4japan.org/">Code for Japan</a>のボランティアたちがまとめたウェブサイトです
        </h3>
        <h3>
            情報収集整理ボランティアへの参加は <a href="https://cfjslackin.herokuapp.com/">こちらのSlack</a> からできます
        </h3>
        <h3>
            システム開発ボランティアへの参加は <a href="https://github.com/arakawatomonori/covid19-surveyor">こちらのGitHub</a> からできます
        </h3>
        <div class="search">
            <form onsubmit="return false;">
                <input type="text" id="searchbox" onkeyup="isearch(this.value)" placeholder="検索する単語をご入力ください">
            </form>
        </div>
        <div class="shares">
            <div class="share">
                <iframe id="twitter-widget-0" scrolling="no" frameborder="0" allowtransparency="true" allowfullscreen="true"
                        class="twitter-share-button twitter-share-button-rendered twitter-tweet-button"
                        style="position: static; visibility: visible; width: 75px; height: 20px;"
                        title="Twitter Tweet Button"
                        src="https://platform.twitter.com/widgets/tweet_button.6787510241df65d128e2b60207ad4c25.ja.html#dnt=true&amp;id=twitter-widget-0&amp;lang=ja&amp;original_referer=http%3A%2F%2Flocalhost%3A63342%2Fcovid19-surveyor%2Fwww-data%2Findex.html%3F_ijt%3Dh23inifumvkt57mm6cqromu6m2&amp;related=codeforJP&amp;size=m&amp;text=%E6%96%B0%E5%9E%8B%E3%82%B3%E3%83%AD%E3%83%8A%E3%82%A6%E3%82%A4%E3%83%AB%E3%82%B9%EF%BC%88COVID-19%EF%BC%89%E5%90%84%E8%87%AA%E6%B2%BB%E4%BD%93%E3%81%AE%E7%B5%8C%E6%B8%88%E6%94%AF%E6%8F%B4%E5%88%B6%E5%BA%A6%E3%81%BE%E3%81%A8%E3%82%81%20&amp;time=1587308822074&amp;type=share&amp;url=https%3A%2F%2Fhelp.stopcovid19.jp%2F&amp;via=codeforJP"
                        data-url="https://help.stopcovid19.jp/">
                </iframe>
            </div>
            <div class="share">
                <a href="https://social-plugins.line.me/lineit/share?url=https://help.stopcovid19.jp/">
                    <img height="20" src="line-share.png">
                </a>
            </div>
            <div class="share">
                <iframe src="https://www.facebook.com/plugins/like.php?href=https%3A%2F%2Fhelp.stopcovid19.jp&width=135&layout=button&action=like&size=small&share=true&height=65"
                        width="135" height="20" style="border:none;overflow:hidden" scrolling="no" frameborder="0"
                        allowTransparency="true" allow="encrypted-media">
                </iframe>
            </div>
        </div>
    </div>
EOM
`
echo $header

wrapper_start=`cat <<EOM
    <div class="contents">
        <div class="content">
            <span id="applicable-number">該当件数: --件</span>
            <ul id="cards">
EOM
`
echo $wrapper_start

. ./lib/url-helper.sh

while read line; do
    orgname=`echo $line| cut -d',' -f 1`
    prefname=`echo $line| cut -d',' -f 2`
    url=`echo $line| cut -d',' -f 3`
    title=`echo $line| cut -d',' -f 4`
    desc=`echo $line| cut -d',' -f 5`
    prefitem=""
    if [ "$prefname" != "" ]; then
        prefitem="<div class="item">$prefname</div>"
    fi
    li=`cat <<EOM
        <li class="card" data-orgname="${orgname}" data-prefname="${prefname}" data-type="" data-target="">
            <div class="card-content">
                <div class="top">
                    <div class="tags">
                        ${prefitem}
                        <div class="item">$orgname</div>
                    </div>
                    <h2>$title</h2>
                    <p>$desc</p>
                </div>
                <div class="bottom">
                    <a class="share-line" href="https://social-plugins.line.me/lineit/share?url=${url}" target="_blank" rel="noopener noreferrer">
                        <img src="line.svg">
                    </a>
                    <a class="share-twitter" href="https://twitter.com/intent/tweet?text=${orgname}がこんな支援制度をやってるよ！ ${title} ${url} 他の支援制度はこちらで探せるよ！ https://help.stopcovid19.jp &via=codeforJP&related=codeforJP" target="_blank" rel="noopener noreferrer">
                        <img src="twitter.svg">
                    </a>
                    <a class="share-facebook" href="https://www.facebook.com/sharer.php?u=${url}" target="_blank" rel="noopener noreferrer">
                        <img src="facebook.svg">
                    </a>
                    <a class="link" href="${url}" target="_blank" rel="noopener noreferrer">
                        <div class="url">$orgname のサイトへ</div>
                    </a>
                </div>
            </div>
            </a>
        </li>

EOM
`
    echo $li
done < reduce.csv

wrapper_end=`cat <<EOM
                    </ul>
        </div>
    </div>
EOM
`
echo $wrapper_end

echo "</body>"
