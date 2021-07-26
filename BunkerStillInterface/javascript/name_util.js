
var name_re = RegExp("^[a-zA-Z_][a-zA-Z_0-9-]*$");
function is_name(name) {
    if (!name_re.test(name)) {
        log.addMessage("(W) Invalid name '" + name + "': must contain only A-Z, a-z, 0-9, '_', '-'");
        return false;
    }
    return true;
}

// Note: May need 'is_qml_name' which is name without '-' character.
//       Such names are legal for qml identifiers.

var stand_in_re = RegExp("^<[a-zA-Z_][a-zA-Z_0-9-]*>$");
function is_stand_in(s) {
    if (!stand_in_re.test(s)) {
        if (s[0] === "<" && s[s.length-1] === ">") {
            // it's genuinely trying to be a stand-in.  Must be a problem with the name part.
            // Warn for invalid name.
            is_name(s.slice(1, -2));
        } else if (s[0] === "<" || s[s.length-1] === ">") {
            log.addMessage("(E) Ill-formed name or standin '" + s + "'");
        }
        return false;
    }
    return true;
}

// Maybe: function test_name(name) returns 2 for standin, 1 for name, 0 for neither.

function connection_name_transform(connection_name) {
    new_name = connection_name.replace(/_/, "-");
    if (new_name !== connection_name) {
        log.addMessage("(W) Connection name changed to '" + new_name + "' to eliminate underscore");
    }
    return new_name;
}
