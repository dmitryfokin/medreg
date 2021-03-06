import { Component } from '../core/component'
import { ListDoctorComponent } from "./list_doctors.component"

export class AppComponent extends Component{

  constructor(id) {
    super(id);
    this.listDoctor = new ListDoctorComponent('list-doctors')
  }

  init() {
    this.show()
    this.listDoctor.show()
  }
}
