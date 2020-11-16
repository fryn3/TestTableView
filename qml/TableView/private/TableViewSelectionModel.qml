import QtQuick 2.12

QtObject {
    id: root

    property int count: 0
    property var model

    property bool __internalNotify: true

    property var __selections: ({})

    signal selectionChanged

    onSelectionChanged: {
       root. __internalNotify = !root.__internalNotify;
    }

    function forEach (callback) {
        if (!(callback instanceof Function)) {
            console.warn("TableViewSelection.forEach: argument is not a function")
            return;
        }
        __forEach(callback)
    }

    function forEachObject (callback) {
        if (!(callback instanceof Function)) {
            console.warn("TableViewSelection.forEachObject: argument is not a function")
            return;
        }
        __forEachObject(callback)
    }

    function contains(index) {
        var item;

        if (index < 0 || index >= rowCount) {
            return false;
        }

        item = root.model.get(index);

        if (!item) {
            return false;
        }

        if (root.__internalNotify) {
            return root.__selections.hasOwnProperty(item);
        }

        return root.__selections.hasOwnProperty(item);
    }

    function containsObj(item) {
        if (!item) {
            return false;
        }

        if (root.__internalNotify) {
            return root.__selections.hasOwnProperty(item);
        }

        return root.__selections.hasOwnProperty(item);
    }

    function clear() {
        root.__selections = {};

        count = 0
        selectionChanged();
    }

    function selectAll() { select(0, rowCount - 1) }
    function select(first, last) { __select(true, first, last) }
    function deselect(first, last) { __select(false, first, last) }

    // --- private section ---

    function __count() {
        return Object.keys(root.__selections).length;
    }

    function __forEachObject(callback) {
        var item,
                callbackArray = [];

        for (var key in root.__selections) {
            item = root.__selections[key];
            callbackArray.push(item.obj);
        }

        for (var i = 0; i < callbackArray.length; ++i) {
            callback.call(this, callbackArray[i]);
        }
    }

    function __forEach(callback) {
        var item;

        for (var key in root.__selections) {
            item = root.__selections[key];
            callback.call(this, root.model.indexOf(item.obj));
        }
    }

    function __selectOne(index) {
        if (index < 0 || index >= rowCount) {
            return;
        }

        var item = root.model.get(index);
        root.__selections = {};
        root.__selections[item] = {obj: item};

        count = 1
        selectionChanged();
    }

    function __select(select, first, last) {
        var i, item

        if (!root.model.get) {
            return
        }

        if (first < 0 || last < 0 || first >= rowCount || last >= rowCount) {
            console.warn("TableViewSelection: index out of range")
            return
        }

        if (last === undefined) {
            item = root.model.get(first);

            if (select) {
                root.__selections[item] = {obj: item};
            } else {
                delete root.__selections[item];
            }

            count = __count();
            selectionChanged() // TODO check if really need
            return;
        }

        if (first <= last) {
            for (i = first; i <= last; ++i) {
                item  = root.model.get(i);

                if (select) {
                    root.__selections[item] = {obj: item};
                } else {
                    delete root.__selections[item];
                }
            }
        } else {
            for (i = first; i >= last; --i) {
                item  = root.model.get(i);

                if (select) {
                    root.__selections[item] = {obj: item};
                } else {
                    delete root.__selections[item];
                }
            }
        }

        count = __count();
        selectionChanged() // TODO check if really need
    }
}
