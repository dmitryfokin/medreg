export class Component {
  constructor(id) {
    this.$el = document.getElementById(id)
    this.init()
  }

  init() {}

  onShow() {}

  onHide() {}

  hide() {
    this.$el.classList.add('d-none')
    this.onHide()
  }

  show() {
    this.$el.classList.remove('d-none')
    this.onShow()
  }
}
