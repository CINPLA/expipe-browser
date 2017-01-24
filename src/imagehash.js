.pragma library

Qt.include("md5.js")

function get(name, size) {
    if(size === undefined) {
        size = 32
    }
//        return "https://robohash.org/" + name + ".png?set=3&size=" + size + "x" + size
    return "http://gravatar.com/avatar/" + md5(name) + "?s=3&d=identicon&r=PG"

}
