function MyAppGetHTMLElementsAtPoint(x,y) {
    var tags = "";
    var e;
    var offset = 0;
    while ((tags.search(",(A|IMG),") < 0) && (offset < 20)) {
        tags = ",";
        e = document.elementFromPoint(x,y+offset);
        while (e) {
            if (e.tagName) {
                tags += e.tagName + ',';
            }
            e = e.parentNode;
        }
        if (tags.search(",(A|IMG),") < 0) {
            e = document.elementFromPoint(x,y-offset);
            while (e) {
                if (e.tagName) {
                    tags += e.tagName + ',';
                }
                e = e.parentNode;
            }
        }
        
        offset++;
    }
    return tags;
}

function MyAppGetLinkSRCAtPoint(x,y) {
    var tags = "";
    var e = "";
    var offset = 0;
    while ((tags.length == 0) && (offset < 20)) {
        e = document.elementFromPoint(x,y+offset);
        while (e) {
            if (e.src) {
                tags += e.src;
                break;
            }
            e = e.parentNode;
        }
        if (tags.length == 0) {
            e = document.elementFromPoint(x,y-offset);
            while (e) {
                if (e.src) {
                    tags += e.src;
                    break;
                }
                e = e.parentNode;
            }
        }
        offset++;
    }
    return tags;
}

function MyAppGetLinkHREFAtPoint(x,y) {
    var tags = "";
    var e = "";
    var offset = 0;
    while ((tags.length == 0) && (offset < 20)) {
        e = document.elementFromPoint(x,y+offset);
        while (e) {
            if (e.href) {
                tags += e.href;
                break;
            }
            e = e.parentNode;
        }
        if (tags.length == 0) {
            e = document.elementFromPoint(x,y-offset);
            while (e) {
                if (e.href) {
                    tags += e.href;
                    break;
                }
                e = e.parentNode;
            }
        }
        offset++;
    }
    return tags;
}
function removeLinks(context) {
    var undefined;
    if(context === undefined) {
        context = document;
    }
    if(!context) {
        return false;
    }
    var links = context.getElementsByTagName('a'), i, link, children, j, parent;
    
    var elements = document.getElementsByTagName('a');
    for (var i = 0; i < elements.length; i++) {
        elements[i].style.display = 'none';
        parent = elements[i].parentNode;
        if(parent)
        {
            parent.style.display = 'none';
        }
    }
    return context;
}

// helper function, recursively searches in elements and their child nodes
function removeAllOccurencesOfStringForElement(element,keyword) {
    if (element) {
        if (element.nodeType == 3) {        // Text node
            while (true) {
                var value = element.nodeValue;  // Search for keyword in text node
                var idx = value.indexOf(keyword);
                
                if (idx < 0)
                    break;             // not found, abort
                element.style.display = "none";
            }
        } else if (element.nodeType == 1) { // Element node
            if (element.style.display != "none" && element.nodeName.toLowerCase() != 'select') {
                for (var i=element.childNodes.length-1; i>=0; i--) {
                    removeAllOccurencesOfStringForElement(element.childNodes[i],keyword);
                }
            }
        }
    }
}
