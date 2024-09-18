class Component {
    __New(name) {
        checkType(name, String, "Parameter #1 is not a string")
        this.name := name
        this.ctrls := []
    }
    
    /**
     * Specify native or AddReactive controls to in component
     * @param {...Gui.Control|...AddReactive} controls 
     */
    Add(controls*) {
        ctrls := []

        for control in controls {
            if (control is Array) {
                this.Add(control*)
            }
            
            if (InStr(Type(Control), "AddReactive")) {
                control.ctrl.groupName := "$$" . this.name
                ctrls.Push(control.ctrl)
            } else {
                control.groupName := "$$" . this.name
                ctrls.Push(control)
            }
        }
        this.ctrls.Push(ctrls*)
    }

    /**
     * Sets the visibility state of the component
     * @param {boolean} isShow 
     */
    visible(isShow) {
        for ctrl in this.ctrls {
            ctrl.visible := isShow
        }
    }

    /**
     * Collects the values from named controls of the component and composes them into an Object.
     * @returns {Object} 
     */
    submit() {
        formData := {}

        for ctrl in this.ctrls {
            if (ctrl.name != "") {
                formData.DefineProp(ctrl.name, { Value: ctrl.Value })
            }
        }

        return formData
    }
}