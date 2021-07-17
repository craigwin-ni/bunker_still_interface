import QtQuick 2.15

ListModel {
    id: pu_assignments_list_model

    property var assignments
    property bool is_datas

    onAssignmentsChanged: {
        update_model();
    }
    onIs_datasChanged: {
        update_model();
    }

    function update_model() {
//        console.log("AssignemntListModel: "+(is_datas? "D":"P") + " assignments=" + assignments);
        clear();
        if (!assignments) return;
        for (let assignment of assignments) {
            append( {"assignment_0": assignment[0],
                     "assignment_1": assignment[1],
                     "assignment_2": assignment[2] || "null",
                     "is_datas": is_datas,
                    });
        }
    }

    function update_assignment(standin, resolution) {
        for (let i_=0; i_<count; i_++) {
            let assignment = get(i_);
            if (assignment.assignment_0 === standin) {
                setProperty(i_, "assignment_1", resolution);  // list model (for display)
                assignments[i_][1] = resolution;  // edited page unit (for ultimate save)
            }
        }
    }
}
