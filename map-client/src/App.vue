<template>
  <div
    id="app"
    class="app"
  >
    <header class="site-header">
      <h1 class="site-title title is-3">
        新型コロナウイルス（COVID-19）各自治体の経済支援制度まとめ（地域検索）
      </h1>
      <p class="site-description">
        全都道府県、全市区町村の新型コロナウイルス（COVID-19）関連の経済支援制度を
        <a href="https://www.code4japan.org/">Code for Japan</a>
        のボランティアたちがまとめたウェブサイトです
      </p>
    </header>

    <main class="main">
      <div
        ref="map"
        class="map"
      />

      <div class="info-area">
        <h2 class="selected-name title is-3">
          {{ selected || '地図上の都道府県を選択してください' }}
        </h2>
        <label class="checkbox cb-national">
          <input
            v-model="includesNationalOffers"
            type="checkbox"
          >
          国からの支援制度も含める
        </label>
        <p class="num-items">
          該当件数:
          <span class="has-text-weight-bold">{{ filteredItems.length }}件</span>
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
              <div class="media-left">
                <span class="tag is-link is-large">{{ item.orgname }}</span>
              </div>
              <div class="media-content">
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
                <a class="button is-primary is-rounded">{{ item.orgname }}のサイトへ</a>
              </p>
            </div>
          </div>
        </div>
      </div>
    </main>
  </div>
</template>

<script>
import jpmap from "japan-map-js"

export default {
  name: "App",
  data() {
    return {
      items: [],
      map: null,
      selected: null,
      includesNationalOffers: false
    }
  },
  computed: {
    filteredItems() {
      return this.items.filter(i =>
        !this.selected ||
        this.selected === i.orgname ||
        this.selected === i.prefname ||
        (this.includesNationalOffers && '省庁'.includes(i.orgname.slice(-1)))
      )
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
      this.selected = data.name
    }
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
}

.site-title {
  color: white;
  line-height: 1.2;
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

.action-area {
  text-align: right;
}

@media screen and (max-width:960px) {
  .info-area,
  .filtered-items {
    padding-left: 8px;
    padding-right: 8px;
  }

  .title.selected-name {
    font-size: 2rem;
  }

  .card-content .media-left .tag {
    font-size: 1rem;
  }
}
</style>
