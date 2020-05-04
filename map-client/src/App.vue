<template>
  <div id="app" class="app">
    <header class="site-header">
      <h1 class="site-title title is-3">
        新型コロナウイルス（COVID-19）各自治体の経済支援制度まとめ
      </h1>
      <p class="site-description">
        全都道府県、全市区町村の新型コロナウイルス（COVID-19）関連の経済支援制度を
        <a class="description-link" href="https://www.code4japan.org/">Code for Japan</a>
        のボランティアたちがまとめたウェブサイトです
      </p>
      <p class="site-description">
        情報収集整理ボランティアへの参加は
        <a class="description-link" href="https://cfjslackin.herokuapp.com/">こちらのSlack</a>
        からできます
      </p>
      <p class="site-description">
        システム開発ボランティアへの参加は
        <a class="description-link" href="https://github.com/arakawatomonori/covid19-surveyor">こちらのGitHub</a>
        からできます
      </p>
    </header>

    <main class="main">
      <div class="search-area">
        <div>
          <label>
            <input
              v-model="searchType"
              value="string"
              type="radio"
              class="radio"
              @change="changedSearchType"
            >
            キーワードで検索する
          </label>
          <transition name="showup">
            <div v-if="isSearchTypeString" class="control search-box">
              <input
                v-model="searchString"
                class="input"
                type="text"
                placeholder="検索する単語をご入力ください"
              >
            </div>
          </transition>
        </div>
        <label>
          <input
            v-model="searchType"
            value="map"
            type="radio"
            class="radio"
            @change="changedSearchType"
          >
          地域から検索する
        </label>
      </div>

      <transition name="showup">
        <div v-show="isSearchTypeMap" class="map-area">
          <p>地図上の都道府県を選択してください</p>
          <vue-simple-map-selector
            class="map"
            @selected="onSelect"
          />
        </div>
      </transition>

      <div class="info-area">
        <h2 class="result-title title is-3">
          {{ resultTitle }}
        </h2>
            
        <label v-if="isSearchTypeMap" class="checkbox cb-national">
          <input
            v-model="includesNationalOffers"
            type="checkbox"
            @change="initDisplayItems"
          >
          国からの支援制度も含める
        </label>
        <p class="num-items">
          該当件数:
          <span class="has-text-weight-bold">
            {{ isLoading ? '--' : filteredItems.length }}件
          </span>
        </p>
      </div>

      <div v-if="isLoading" class="loading">
        <div class="icon">
          <i class="fa fa-spinner fa-pulse"></i>
        </div>
      </div>
      <div v-else class="filtered-items">
        <div v-for="(item, i) in displayItems" :key="i" class="card">
          <div class="card-content">
            <div class="media">
              <div class="media-content">
                <span v-if="item.prefname" class="tag prefname">
                  {{ item.prefname }}
                </span>
                <span class="tag orgname">{{ item.orgname }}</span>
                <span class="item-index">
                  {{ i + 1 }} / {{ filteredItems.length }}
                </span>
                <h3 class="title is-4" v-html="highlight(item.title)"></h3>
              </div>
            </div>
            <div class="content">
              <p class="subtitle is-6" v-html="highlight(clipDesc(item.description))"></p>
              <div class="action-area is-clearfix">
                <div class="share-buttons is-pulled-left">
                  <a class="share-button" :href="shareLineURL(item)" target="_blank" rel="noopener noreferrer">
                    <img src="line.svg">
                  </a>
                  <a class="share-button" :href="shareTwitterURL(item)" target="_blank" rel="noopener noreferrer">
                    <img src="twitter.svg">
                  </a>
                  <a class="share-button" :href="shareFBURL(item)" target="_blank" rel="noopener noreferrer">
                    <img src="facebook.svg">
                  </a>
                </div>

                <a class="jump-button button is-primary is-rounded is-pulled-right" :href="item.url" target="_blank" rel="noopener">
                  <span>{{ item.orgname }}のサイトへ</span>
                  <span class="icon is-small">
                    <i class="fa fa-external-link" aria-label="外部サイトに移動します"></i>
                  </span>
                </a>
              </div>
            </div>
          </div>
        </div>
        <infinite-loading
          @infinite="infiniteHandler"
          :identifier="searchString + selectedPref"
          spinner="circles"
        >
          <div slot="no-more">一致した全ての支援制度を表示しました</div>
          <div slot="no-results">一致する支援制度は見つかりませんでした</div>
        </infinite-loading>
      </div>
    </main>
  </div>
</template>

<script>
import Vue from 'vue'
import InfiniteLoading from 'vue-infinite-loading';
import VueSimpleMapSelector from 'vue-simple-map-selector'
import { debounce } from 'debounce'

Vue.use(InfiniteLoading)

const MAX_DESC_LENGTH = 200     // description の最大文字数
const INPUT_DEBOUNCE_TIME = 300 // 検索欄の入力確定までの遅延時間(ms)

export default {
  name: "App",
  components: {
    VueSimpleMapSelector
  },
  data() {
    return {
      allItems: [],
      selectedPref: '',
      includesNationalOffers: false,
      searchType: 'string',
      searchString: '',
      isLoading: true,
      displayItems: [],
      page: 0,
      perPage: 10
    }
  },
  computed: {
    resultTitle() {
      if (this.isSearchTypeString) {
        return this.searchString
          ? `キーワード: ${this.searchString}`
          : '全ての経済支援制度'
      }
      return this.selectedPref
        ? `地域: ${this.selectedPref}`
        : '全ての経済支援制度'
    },
    isSearchTypeString() {
      return this.searchType === 'string'
    },
    isSearchTypeMap() {
      return this.searchType === 'map'
    },
    filteredItems() {
      if (this.isSearchTypeString) {
        return this.searchString
          ? this.allItems.filter(i => this.isMatchPattern(i))
          : this.allItems
      } else {
        return this.selectedPref
          ? this.allItems.filter(i => this.isSelectedPref(i))
          : this.allItems
      }
    }
  },
  mounted() {
    this.loadItems()
  },
  methods: {
    loadItems() {
      this.isLoading = true
      fetch(process.env.VUE_APP_JSON_PATH)
        .then(resp => resp.json())
        .then(json => {
          this.allItems = json
          this.initDisplayItems()
          this.isLoading = false
        })
    },
    onSelect(pref) {
      const prefName = pref && pref.name
      console.log(prefName)
      if (this.selectedPref !== prefName) {
        this.selectedPref = prefName
        this.initDisplayItems()
      }
    },
    isMatchPattern(item) {
      return (item.title + item.orgname + item.prefname + item.description)
        .match(this.searchString)
    },
    isSelectedPref(item) {
      return this.selectedPref === item.orgname ||
        this.selectedPref === item.prefname ||
        (this.includesNationalOffers && '省庁'.includes(item.orgname.slice(-1)))
    },
    changedSearchType() {
      this.selectedPref = ''
      this.searchString = ''
    },
    shareLineURL(item) {
      return `https://social-plugins.line.me/lineit/share?url=${item.url}`
    },
    shareTwitterURL(item) {
      return `https://twitter.com/intent/tweet?text=${item.orgname}がこんな支援制度をやってるよ！ ${item.url} 他の支援制度はこちらで探せるよ！ https://help.stopcovid19.jp &via=codeforJP&related=codeforJP`
    },
    shareFBURL(item) {
      return `https://www.facebook.com/sharer.php?u=${item.url}`
    },
    clipDesc(desc) {
      const sanitized = desc.replace(/&\w+;/g, ' ')
      return sanitized.length > MAX_DESC_LENGTH
        ? sanitized.slice(0, MAX_DESC_LENGTH) + '…'
        : sanitized
    },
    infiniteHandler($state) {
      this.appendItems()

      if (this.displayItems.length > 0) $state.loaded()
      if (this.displayItems.length >= this.filteredItems.length) $state.complete()
    },
    initDisplayItems() {
      this.page = 0
      this.displayItems = []
      this.appendItems()
    },
    appendItems() {
      const index = this.page * this.perPage
      if (this.filteredItems.length > index) {
        const slice = this.filteredItems.slice(index, index + this.perPage)
        this.displayItems.push(...slice)
        this.page += 1
      }
    },
    highlight(str) {
      if (!this.searchString) return str
      const re = new RegExp(`(${this.searchString})`, 'gi')
      return str.replace(re, '<em>$1</em>')
    }
  },
  watch: {
    searchString: debounce(function() {
      this.initDisplayItems()
    }, INPUT_DEBOUNCE_TIME)
  }
}
</script>

<style lang="scss">
.app {
  width: 100%;
  margin: 0 auto;
}

.site-header {
  background: #ac0027;
  padding: 24px;
  color: white;

  .site-title {
    color: white;
    line-height: 1.2;
  }

  .description-link {
    text-decoration: underline;
    color: white;
    padding: 0 4px;

    &:hover {
      text-decoration: none;
    }
  }
}

.main {
  margin: 32px auto;
  width: 100%;
  max-width: 960px;
}

.map {
  margin: 4px auto 32px;
  width: 100%;
  max-width: 960px;
  height: 75vw;
  max-height: 720px;
  border: solid 1px gray;
  padding: 1vw;
}

.info-area {
  margin: 32px 0;

  .cb-national {
    margin-bottom: 16px;
  }
}

.card {
  margin-bottom: 24px;
  width: 100%;
}

.media-content {
  overflow-x: unset;
}

.card-title {
  font-size: 1.5rem;
  line-height: 1.5;
}

.card-content {
  .tag {
    background: white;
    color: #3273dc;
    border: solid 1px #3273dc;
    font-weight: bold;
    font-size: 0.9rem;
    margin-bottom: 12px;

    &.prefname {
      margin-right: 8px;
    }
  }

  .item-index {
    float: right;
    color: #ddd;
  }

  em {
    background: #ffa;
    font-style: normal;
  }
}

.action-area {
  margin-top: 16px;

  .share-buttons {
    margin-top: 8px;
  }

  .share-button {
    display: inline-block;
    width: 40px;
    height: 40px;
    margin-right: 12px;

    img:hover {
      opacity: 0.5;
    }
  }

  .jump-button {
    margin-top: 8px;
  }
}

.showup-enter-active, .showup-leave-active {
  max-height: 1000px;
  transition: max-height 1s ease-in-out;
  overflow: hidden;
}
.showup-enter, .showup-leave-to {
  max-height: 0;
  transition: max-height 0.5s cubic-bezier(0, 1, 0, 1);
  overflow: hidden;
}

.search-area {
  margin-bottom: 16px;

  .search-box {
    margin: 8px 0 8px 1rem;
  }
}

label {
  cursor: pointer;
}

.loading {
  text-align: center;
  font-size: 2rem;
  min-height: 320px;
}

@media screen and (max-width:960px) {
  .info-area,
  .search-area,
  .filtered-items {
    padding-left: 8px;
    padding-right: 8px;
  }

  .title.result-title {
    font-size: 2rem;
  }

  .card-content .media-left .tag {
    font-size: 1rem;
  }

  .share-button {
    margin-right: 8px;
  }
}
</style>
