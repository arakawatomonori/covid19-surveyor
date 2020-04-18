#!/bin/bash
set -e

###
### About
### help.stopcovid19.jp/index.htmlを生成するスクリプト
###
### Usage
### ./index.sh
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
    <meta property="og:description" content="全都道府県、全市区町村の新型コロナウイルス（COVID-19）関連の経済支援制度をCode for japanのボランティアたちがまとめたウェブサイトです">
    <meta property="og:type" content="website">
    <meta property="og:url" content="https://help.stopcovid19.jp/">
    <meta property="og:image" content="https://help.stopcovid19.jp/ogimg.png">
    <meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no">
    <style type="text/css">
        .card-content {
            cursor: pointer;
            border-radius: 6px;
            box-shadow: rgba(0, 0, 0, 0.04) 0px 1px 18px;
            background-color: rgb(255, 255, 255);
            margin: 1em 0px;
            line-height: 1.8em;
        }

        .card-content:hover {
            box-shadow: rgba(0, 0, 0, 0.12) 0px 1px 18px;
        }

        .card-content:hover > .bottom > .url {
            background-color: rgb(94, 77, 187);
            color: rgb(255, 255, 255);
        }

        .card-content > .top {
            padding: 32px 20px;
        }

        .card-content > .top > p {
            color: rgb(51, 51, 51);
        }

        .card-content > .top > h2 {
            margin-bottom: 16px;
            color: rgb(51, 51, 51);
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


        .card-content > .bottom > .url {
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
        }

        @media (max-width: 450px) {
            .card-content > .top {
                padding: 32px 20px;
            }

            .card-content > .bottom {
                padding: 20px;
            }

            .card-content > .bottom > .url {
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
            background-color:  #bf0025;
            padding-bottom: 25px;
        }

        .header > .title {
            margin: 0px;
            padding: 30px 0px 20px;
            color: white;
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

        *, ::before, ::after {
            box-sizing: border-box;
            list-style: none;
            text-decoration: none;
            margin: 0;
            padding: 0;
        }

        h1, h2, p {
            margin: 0px;
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

    <script>window.twttr = (function(d, s, id) {
        var js, fjs = d.getElementsByTagName(s)[0],
        t = window.twttr || {};
        if (d.getElementById(id)) return t;
        js = d.createElement(s);
        js.id = id;
        js.src = "https://platform.twitter.com/widgets.js";
        fjs.parentNode.insertBefore(js, fjs);

        t._e = [];
        t.ready = function(f) {
        t._e.push(f);
        };

        return t;
        }(document, "script", "twitter-wjs"));
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
        <a class="twitter-share-button"
            href="https://twitter.com/intent/tweet?text=%90V%8C%5E%83R%83%8D%83i%83E%83C%83%8B%83X%81iCOVID-19%81j%8Ae%8E%A9%8E%A1%91%CC%82%CC%8Co%8D%CF%8Ex%89%87%90%A7%93x%82%DC%82%C6%82%DF"
            data-size="large"
            style="transform:scale(3.0, 3.0);"
            >
            Tweet
        </a>
        <div class="search">
						<form onsubmit="return false;">
							<input type="text" id="searchbox" onkeyup="isearch(this.value)" placeholder="検索する単語をご入力ください">
						</form>
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

keys=`redis-cli KEYS "vscovid-crawler:result-*"`
for key in $keys; do
	result=`redis-cli GET $key`
	bool=`echo $result| cut -d',' -f 4`
	if [ $bool = "true" ]; then
		url=`echo $result| cut -d',' -f 1`
		# ドメイン名から自治体名を得る
		domain=$(cut -d'/' -f 3 <<< $url)
		govname=`grep $domain --include="*.csv" ./data/*|cut -d',' -f 1|cut -d':' -f 2`
		# urlから詳細を得る
		path=${url//http:\/\//}
		path=${path//https:\/\//}
		# urlからタイトルを得る
		title=`grep $path ./result.txt |cut -d':' -f 2`
		li=`cat <<EOM
			<li class="card">
					<a href="${url}" target="_blank"
							rel="noopener noreferrer">
							<div class="card-content">
									<div class="top">
											<h2>$title</h2>
											<p>$govname から提供されています。</p>
									</div>
									<div class="bottom">
											<div class="url">詳細を確認する</div>
									</div>
							</div>
					</a>
			</li>
EOM
`
		echo $li
	fi
done

wrapper_end=`cat <<EOM
					</ul>
        </div>
    </div>
EOM
`
echo $wrapper_end

echo "</body>"
