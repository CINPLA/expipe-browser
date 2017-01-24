.pragma library

Qt.include("md5.js")

function get(name, size) {
    if(size === undefined) {
        size = 32
    }
    return "https://robohash.org/" + name + ".png?bgset=bg1&set=set1&size=" + size + "x" + size
//    return "http://gravatar.com/avatar/" + md5(name) + "?s=" + size + "&d=identicon&r=PG"

}

function action(data) {
    if(data.subjects && data.subjects.length > 0) {
        return get(data.subjects[0], 64)
    } else {
        return get(data.id, 64)
    }
}
