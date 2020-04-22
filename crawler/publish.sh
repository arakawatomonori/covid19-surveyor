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

        h1, h2, p {
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
    <script>
        function quotemeta(string) {
            return string.replace(/(\W)/, "$1");
        }

        function isearch(pattern) {
            var regex = new RegExp(quotemeta(pattern), "i");
            var spans = document.getElementsByTagName('li');
            var length = spans.length;
            var applis = 0;
            for (var i = 0; i < length; i++) {
                var e = spans[i];
                if (e.className === "card") {
                    if (e.innerHTML.match(regex)) {
                        e.style.display = "list-item";
                        applis += 1;
                    } else {
                        e.style.display = "none";
                    }
                }
            }
            const elem = document.getElementById("applicable-number");
            elem.textContent = '該当件数:' + applis + '件';
        }

        function applicable() {
            const ulElement = document.getElementById("cards");
            const childElementCount = ulElement.childElementCount;
            const elem = document.getElementById("applicable-number");
            elem.textContent = '該当件数:' + childElementCount + '件';
        }

        window.onload = function () {
            applicable()
        }
    </script>
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
        <h2>
            全都道府県、全市区町村の新型コロナウイルス（COVID-19）関連の経済支援制度を<a href="https://www.code4japan.org/">Code for Japan</a>のボランティアたちがまとめたウェブサイトです
        </h2>
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
    url=`echo $line| cut -d',' -f 2`
    title=`echo $line| cut -d',' -f 3`
    desc=`echo $line| cut -d',' -f 4`
    prefname=`get_prefname_by_url $url`
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
                        <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 120 120">
                            <defs>
                                <style>
                                    .cls-1 {
                                        fill: #00b900;
                                    }

                                    .cls-2 {
                                        fill: #fff;
                                    }
                                </style>
                            </defs>
                            <g id="レイヤー_2" data-name="レイヤー 2">
                                <g id="LINE_LOGO" data-name="LINwE LOGO">
                                    <circle class="cls-1" cx="60" cy="60" r="60"/>
                                    <g id="TYPE_A" data-name="TYPE A">
                                        <path class="cls-2"
                                              d="M99.91,56.4C99.91,38.54,82,24,60,24S20.09,38.54,20.09,56.4c0,16,14.2,29.42,33.38,31.95,1.3.28,3.07.86,3.51,2a8,8,0,0,1,.13,3.61l-.57,3.41c-.17,1-.8,4,3.46,2.15S83,86,91.36,76.32h0C97.14,70,99.91,63.54,99.91,56.4"/>
                                        <path class="cls-1"
                                              d="M51.89,47.77h-2.8a.78.78,0,0,0-.78.77V65.93a.78.78,0,0,0,.78.78h2.8a.78.78,0,0,0,.78-.78V48.54a.78.78,0,0,0-.78-.77"/>
                                        <path class="cls-1"
                                              d="M71.16,47.77h-2.8a.78.78,0,0,0-.78.77V58.87l-8-10.76L59.55,48h0l0-.05h0s0,0,0,0h0l0,0h0l0,0h0l0,0H56.17a.78.78,0,0,0-.78.77V65.93a.78.78,0,0,0,.78.78H59a.77.77,0,0,0,.77-.78V55.61l8,10.77a.89.89,0,0,0,.2.19h0l0,0h0l0,0h.06l.05,0h0a.64.64,0,0,0,.2,0h2.8a.78.78,0,0,0,.78-.78V48.54a.78.78,0,0,0-.78-.77"/>
                                        <path class="cls-1"
                                              d="M45.14,62.35h-7.6V48.54a.78.78,0,0,0-.78-.77H34a.78.78,0,0,0-.78.77V65.93h0a.8.8,0,0,0,.22.54h0a.76.76,0,0,0,.54.22H45.14a.78.78,0,0,0,.78-.78v-2.8a.78.78,0,0,0-.78-.78"/>
                                        <path class="cls-1"
                                              d="M86.62,52.12a.77.77,0,0,0,.77-.78V48.55a.77.77,0,0,0-.77-.78H75.43a.73.73,0,0,0-.53.22h0l0,0a.78.78,0,0,0-.21.53h0V65.93h0a.76.76,0,0,0,.22.54h0a.75.75,0,0,0,.53.22H86.62a.77.77,0,0,0,.77-.78v-2.8a.77.77,0,0,0-.77-.78H79V59.42h7.61a.77.77,0,0,0,.77-.78v-2.8a.77.77,0,0,0-.77-.78H79V52.12Z"/>
                                    </g>
                                </g>
                            </g>
                        </svg>
                    </a>
                    <a class="share-twitter" href="https://twitter.com/intent/tweet?text=${orgname}がこんな支援制度をやってるよ！ ${title} ${url} 他の支援制度はこちらで探せるよ！ https://help.stopcovid19.jp &via=codeforJP&related=codeforJP" target="_blank" rel="noopener noreferrer">
                        <svg version="1.1" xmlns="http://www.w3.org/2000/svg"
                             xmlns:xlink="http://www.w3.org/1999/xlink" x="0px" y="0px"
                             viewBox="0 0 400 400" style="enable-background:new 0 0 400 400;" xml:space="preserve">
                            <style type="text/css">
                                .st0 {
                                    fill: #1DA1F2;
                                }

                                .st1 {
                                    fill: #FFFFFF;
                                }
                            </style>
                            <g id="Dark_Blue">
                                <circle class="st0" cx="200" cy="200" r="200"/>
                            </g>
                            <g id="Logo__x2014__FIXED">
                                <path class="st1" d="M163.4,305.5c88.7,0,137.2-73.5,137.2-137.2c0-2.1,0-4.2-0.1-6.2c9.4-6.8,17.6-15.3,24.1-25
                                    c-8.6,3.8-17.9,6.4-27.7,7.6c10-6,17.6-15.4,21.2-26.7c-9.3,5.5-19.6,9.5-30.6,11.7c-8.8-9.4-21.3-15.2-35.2-15.2
                                    c-26.6,0-48.2,21.6-48.2,48.2c0,3.8,0.4,7.5,1.3,11c-40.1-2-75.6-21.2-99.4-50.4c-4.1,7.1-6.5,15.4-6.5,24.2
                                    c0,16.7,8.5,31.5,21.5,40.1c-7.9-0.2-15.3-2.4-21.8-6c0,0.2,0,0.4,0,0.6c0,23.4,16.6,42.8,38.7,47.3c-4,1.1-8.3,1.7-12.7,1.7
                                    c-3.1,0-6.1-0.3-9.1-0.9c6.1,19.2,23.9,33.1,45,33.5c-16.5,12.9-37.3,20.6-59.9,20.6c-3.9,0-7.7-0.2-11.5-0.7
                                    C110.8,297.5,136.2,305.5,163.4,305.5"/>
                            </g>
                        </svg>
                    </a>
                    <a class="share-facebook" href="https://www.facebook.com/sharer.php?u=${url}" target="_blank" rel="noopener noreferrer">
                        <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 1024 1024">
                            <defs>
                                <style>.face-1 {
                                    fill: #1877f2;
                                }

                                .face-2 {
                                    fill: #fff;
                                }</style>
                            </defs>
                            <g id="レイヤー_2" data-name="レイヤー 2">
                                <g id="Layer_1" data-name="Layer 1">
                                    <path class="face-1"
                                          d="M1024,512C1024,229.23,794.77,0,512,0S0,229.23,0,512c0,255.55,187.23,467.37,432,505.78V660H302V512H432V399.2C432,270.88,508.44,200,625.39,200c56,0,114.61,10,114.61,10V336H675.44c-63.6,0-83.44,39.47-83.44,80v96H734L711.3,660H592v357.78C836.77,979.37,1024,767.55,1024,512Z"/>
                                    <path class="face-2"
                                          d="M711.3,660,734,512H592V416c0-40.49,19.84-80,83.44-80H740V210s-58.59-10-114.61-10C508.44,200,432,270.88,432,399.2V512H302V660H432v357.78a517.58,517.58,0,0,0,160,0V660Z"/>
                                </g>
                            </g>
                        </svg>
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
