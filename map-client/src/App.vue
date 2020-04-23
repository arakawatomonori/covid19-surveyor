<template>
  <div
    id="app"
    class="app"
  >
    <header class="site-header">
      <h1 class="site-title title is-3">
        新型コロナウイルス（COVID-19）各自治体の経済支援制度まとめ
      </h1>
      <p class="site-description">
        全都道府県、全市区町村の新型コロナウイルス（COVID-19）関連の経済支援制度を
        <a
          class="description-link"
          href="https://www.code4japan.org/"
        >Code for Japan</a>
        のボランティアたちがまとめたウェブサイトです
      </p>
      <p class="site-description">
        情報収集整理ボランティアへの参加は <a
          class="description-link"
          href="https://cfjslackin.herokuapp.com/"
        >こちらのSlack</a> からできます
      </p>
      <p class="site-description">
        システム開発ボランティアへの参加は <a
          class="description-link"
          href="https://github.com/arakawatomonori/covid19-surveyor"
        >こちらのGitHub</a> からできます
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
            <div
              v-if="isSearchTypeString"
              class="control search-box"
            >
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
          地図から検索する
        </label>
      </div>

      <transition name="showup">
        <div
          v-show="isSearchTypeMap"
          class="map-area"
        >
          <p>地図上の都道府県を選択してください</p>
          <div
            ref="map"
            class="map"
          />
        </div>
      </transition>

      <div class="info-area">
        <h2 class="result-title title is-3">
          {{ resultTitle }}
        </h2>
            
        <label
          v-if="isSearchTypeMap"
          class="checkbox cb-national"
        >
          <input
            v-model="includesNationalOffers"
            type="checkbox"
          >
          国からの支援制度も含める
        </label>
        <p class="num-items">
          該当件数:
          <span class="has-text-weight-bold">
            {{ filteredItems.length }}件
          </span>
        </p>
      </div>

      <div class="filtered-items">
        <div
          v-for="(item, i) in filteredItems"
          :key="i"
          class="card"
        >
          <div class="card-content">
            <div class="media">
              <div class="media-content">
                <span
                  v-if="item.prefname"
                  class="tag prefname"
                >
                  {{ item.prefname }}
                </span>
                <span class="tag orgname">{{ item.orgname }}</span>
                <h3 class="title is-4">
                  {{ item.title }}
                </h3>
              </div>
            </div>
            <div class="content">
              <p class="subtitle is-6">
                {{ item.description }}
              </p>
              <p class="action-area">
                <a
                  class="button is-primary is-rounded"
                  :href="item.url"
                >{{ item.orgname }}のサイトへ</a>
              </p>
            </div>
          </div>
        </div>
      </div>
    </main>
  </div>
</template>

<script>
import jpmap from 'japan-map-js'

export default {
  name: "App",
  data() {
    return {
      items: [],
      map: null,
      selectedPref: null,
      includesNationalOffers: false,
      searchType: 'string',
      searchString: ''
    }
  },
  computed: {
    filteredItems() {
      return this.items.filter(i => {
        if (this.isSearchTypeString) {
          return this.searchString && this.isMatchPattern(i)
        } else {
          return this.selectedPref && (
            this.selectedPref === i.orgname ||
            this.selectedPref === i.prefname ||
            (this.includesNationalOffers && '省庁'.includes(i.orgname.slice(-1)))
          )
        }
      })
    },
    resultTitle() {
      if (this.isSearchTypeString) {
        return this.searchString
          ? `キーワード: ${this.searchString}`
          : '検索結果'
      }
      return this.selectedPref
        ? `地域: ${this.selectedPref}`
        : '検索結果'
    },
    isSearchTypeString() {
      return this.searchType === 'string'
    },
    isSearchTypeMap() {
      return this.searchType === 'map'
    }

  },
  mounted() {
    this.setupMap()
    this.loadItems()
  },
  methods: {
    loadItems() {
      fetch(process.env.VUE_APP_JSON_PATH)
        .then(resp => resp.json())
        .then(json => {
          this.items = json
        })
    },
    setupMap() {
      if (!this.map) {
        this.map = new jpmap.japanMap(this.$refs.map, {
          showsPrefectureName: true,
          width: 960,
          movesIslands: true,
          lang: "ja",
          onSelect: this.onSelect
        })
      }
    },
    onSelect(data) {
      console.log(data.name)
      this.selectedPref = data.name
    },
    isMatchPattern(item) {
      return (item.title + item.orgname + item.prefname + item.description)
        .match(this.searchString)
    },
    changedSearchType() {
      this.selectedPref = ''
      this.searchString = ''
    }
  }
}
</script>

<style lang="scss">
.app {
  width: 100%;
  margin: 0 auto;
}

.site-header > .site-description {
  color: white;
}

.site-header > .site-description > .description-link  {
  text-decoration: underline;
  color: white;
  padding: 0 4px;
}

.site-header > .site-description > .description-link:hover {
  text-decoration: none;
}

.site-header {
  background: #ac0027;
  padding: 24px;
}

.site-title {
  color: white;
  line-height: 1.2;
}

.site-header .p {
  color: white;
}

.main {
  margin: 32px auto;
  width: 100%;
  max-width: 960px;

  canvas {
    width: 100%;
  }
}

.info-area {
  margin: 32px 0;
}

.cb-national {
  margin-bottom: 16px;
}

.card {
  margin-bottom: 24px;
  width: 100%;
}

.card-title {
  display: flex;
  align-items: baseline;
  font-size: 1.5rem;
  line-height: 1.5;
}

.card-content {
  .tag {
    background: transparent;
    color: #3273dc;
    border: solid 1px #3273dc;
    font-weight: bold;
    font-size: 0.9rem;
    margin-bottom: 12px;

    &.prefname {
      margin-right: 8px;
    }
  }
}

.action-area {
  text-align: right;
}

.text {
  overflow: hidden;
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
}
.search-box {
  margin: 8px 0 8px 1rem;
}

label {
  cursor: pointer;
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
}
</style>
