class Component {
    /**
     * Create a component instance.
     * ```
     * comp := Component(guiObj, "componentName")
     * 
     * Comp(guiObj) {
     *   c := Component(guiObj, A_ThisFunc)
     *   ; ...
     *   return c
     * }
     * ```
     * @param {String} name The unique name of the component
     * @param {Object} props 
     */
    __New(GuiObj, name, props := {}) {
        checkType(name, String, "Parameter #1 is not a string")
        this.GuiObj := GuiObj
        this.name := name
        this.props := {}
        this.ctrls := []
        this.children := () => {}
        this.childComponents := []
        
        this.defineProps(props)
        this.defineChildren()
        GuiObj.components.Push(this)
    }

    /**
     * Specify native or AddReactive controls to in component
     * @param {...Gui.Control|...AddReactive} controls 
     * @returns {Component}
     */
    Add(controls*) {
        saveControls(ctrlsArray, controls) {
            for control in controls {
                ; native control
                if (control is Gui.Control) {
                    control.groupName := "$$" . this.name
                    ctrlsArray.Push(control)
                }

                ; AddReactive control
                if (Control is AddReactive) {
                    control.ctrl.groupName := "$$" . this.name
                    ctrlsArray.Push(control.ctrl)
                }

                ; Array
                if (control is Array) {
                    saveControls(ctrlsArray, control)
                }

                ; IndexList
                if (control is IndexList) {
                    for listControl in control.ctrlGroups {
                        saveControls(ctrlsArray, listControl)
                    }
                }

                ; nested component
                if (control is Component) {
                    this.childComponents.Push(control)
                }
            }
        }

        ctrls := []
        saveControls(ctrls, controls)
        this.ctrls.Push(ctrls*)

        return this
    }

    /**
     * Define additional props
     * @param {Object} props props Object
     */
    defineProps(props) {
        checkType(props, Object.Prototype)
        
        for name, val in props.OwnProps() {
            if (name == this.name) {
                this.props := val
            }
        }
    }

    defineChildren() {
        if (this.props.HasOwnProp("children")) {
            this.children := this.props.children.Bind(this.GuiObj)
        }
    }

    /**
     * Sets the visibility state of the component
     * @param {boolean} isShow 
     */
    visible(isShow) {
        state := isShow is Func ? isShow() : isShow

        for ctrl in this.ctrls {
            ctrl.visible := state
        }

        this._handleChildComponentVisible(state, this.childComponents)
    }

    _handleChildComponentVisible(state, childComponents) {
        if (childComponents.Length == 0) {
            return
        }

        for component in childComponents {
            component.visible(state)
            if (component.childComponents.Length > 0) {
                this._handleChildComponentVisible(state, component.childComponents)
            }
        }
    }

    /**
     * Collects the values from named controls of the component and composes them into an Object.
     * @returns {Object} 
     */
    submit(hide := false) {
        if (hide == true) {
            this.GuiObj.hide()
        }

        formData := {}

        for ctrl in this.ctrls {
            if (ctrl.name != "") {
                formData.DefineProp(ctrl.name, { Value: ctrl.Value })
            }
        }

        this._handleChildComponentSubmit(formData, this.childComponents)

        return formData
    }

    _handleChildComponentSubmit(dataObj, childComponents) {
        if (childComponents.Length == 0) {
            return
        }

        for component in childComponents {
            componentFormData := component.submit()
            if (component.childComponents.Length > 0) {
                this._handleChildComponentSubmit(componentFormData, component.childComponents)
            }
            dataObj.DefineProp(component.name, { Value: componentFormData })
        }
    }

    disable(disabled) {
        state := disabled is Func ? disabled() : disabled

        for ctrl in this.ctrls {
            ctrl.Enabled := !state
        }

        this._handleChildComponentDisable(state, this.childComponents)
    }

    _handleChildComponentDisable(state, childComponents) {
        if (childComponents.Length == 0) {
            return
        }

        for component in childComponents {
            component.disable(state)
            if (component.childComponents.Length > 0) {
                this._handleChildComponentDisable(state, component.childComponents)
            }
        }
    }
}

Gui.Prototype.components := []