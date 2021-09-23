import QtQuick 2.15
import "../BsiDisplayObjects"

QtObject {
    id: componentStore

    property var component_sets: ({})
    property var components: null

    property int compstore_state: 0  // 0: disconnected, 1: connected
    property var subscription: null

    property var component_proxy: Component {
        // Note: do not confuse the QML Component type with components used by bunkerbox.
        //       Component (uppercase 'C') is a QML type to define new QML object type.
        //       component* (lowercase 'c'} refers the unit of data exchanged between this
        //       UI and the bunkerbox controller software.

        id: component_proxy
        // This indirect passing of component data provides for signalling via onValueChanged().

        QtObject {
            property string name: ""
            property var value: null
            property var details: null

            property int precision: 4

            function update(jsobj) {
                name = jsobj.id;
                value = jsobj.value;
                details = jsobj;
            }

            function setValue(new_value) {
                componentStore.set_component_value(new_value);
            }

            function getValueText(prec) {
                var text, units;
                if (!details) return null;

                if (!prec) prec = precision;

                if (value === null) return "null";
                if (value === undefined) return "undefined";

                switch (details.type) {
                case "TEXT":       // fall through
                case "BIG_TEXT":   // fall through
                case "OPTIONS":
                    text = value;
                    break;

                case "BOOLEAN":
                    text = value? "T" : "F";
                    break;

                case "BUTTON":
                    text = value? "1" : "0";
                    break;

                case "NUMBER":
                    text = value.toPrecision(prec);
                    break;
                }

                units = details.units;
                if (units) return text + " " + units;

                return text;
            }
        }
    }

    property var mqtt_handlers: Connections {
        target: mqtt

        function onConnection_made() {
            log.addMessage("BsiComponentStore connected.")

            // set up component storage for this still
            let still = status_banner.connected_still
            if (!still) {
                components = null
            } else {
                if (!component_sets[still]) component_sets[still] = {};
                components = component_sets[still];
            }

            compstore_state = 1;

            // subscribe to message feed and connect message handler
            if (subscription) subscription.destroy();
            subscription = mqtt.make_subscription("read/+/+/+/detail");
            log.addMessage("BsiComponentStore subcription received.")
            subscription.messageReceived.connect(update_component);
        }

        function onConnection_lost() {
            log.addMessage("BsiComponentStore disconnected.")
            if (subscription) subscription.destroy();
            subscription = null;
            compstore_state = 0;
        }
    }

    function update_component(payload) {
        if (payload) {
            let updated_comp = JSON.parse(payload);
            let comp = components[updated_comp.id];
            if (!comp) {
                // create new proxy
                comp = components[updated_comp.id] = component_proxy.createObject(main_window);
            }
            comp.update(updated_comp);
        }
    }

    function get_component_names() {
        // return names ordered by group, display_order
//        if (!compstore_state) return undefined;
        if (!components) return [];
        let comps = Object.values(components)
        comps.sort(function(a, b) {
                if (a.details && !b.details) return -1;
                if (!a.details && b.details) return 1;
                if (!a.details && !b.details) return 0;

                // compare group names
                if (a.details.group < b.details.group) return -1;
                if (a.details.group > b.details.group) return 1;

                // a and b are in same group
                if ((a.details.display_order || 1e6) < (b.details.display_order || 1e6)) return -1;
                if ((a.details.display_order || 1e6) > (b.details.display_order || 1e6)) return 1;

                // a is equal to b
                return 0;
            });

        return comps.map(a => a.name)
    }

    function get_group_names() {
        // return list of group names in alpha-numeric sort order
        if (!compstore_state) return undefined;
        if (!components) return [];
        let unique_group_names = [...new Set(Object.values(components)
                                             .map(comp=>(comp.details)? comp.details.group : "undefined"))];
        unique_group_names.sort();
        return unique_group_names;
    }

    function get_grouped_component_names() {
        // return object keyed by group names containing group component ids in display order
//        if (!compstore_state) return undefined;
        if (!components) return {};
        let comp_names = get_component_names()
        var grouped_names = {};
        for (let name of comp_names) {
            if (!name) continue;
            let component = components[name];
            let group = component.details? component.details.group : "undefined";
            if (grouped_names[group] === undefined) grouped_names[group] = [];
            grouped_names[group].push(component.name);
        }

        return grouped_names;
    }

    function get_component(name) {
        if (!compstore_state) return null;
        if (!name) return null;
        let comp = components[name];
        if (!comp) {
            comp = components[name] = component_proxy.createObject(main_window)
            if (!comp.name) comp.name = name;
        }
        return components[name];
    }

    function get_component_value(name) {
        if (!components[name]) return null;
        return compoennts[name].value;
    }

    function set_component_value(name, new_value) {
        if (!compstore_state) {
            log.addMessage("Attempt to set component '" + name + "' while disconnected.");
            return;
        }

        var comp = components[name];
        if (!comp) {
            log.addMessage("Attempt to set non-existant component '" + name + "' to '" + new_value + "'.");
            return;
        }

        // Publish a message to have value updated
        let topic = "write/" + component_id;
        let message = JSON.stringify(new_value);
        componentStore.component_mqtt_client.publish(topic, message, 0, true);

        // update local copy  ??? should we wait for the detail message this change will generate
//        comp.value = value;
    }
}
