// Utility functions for machine design
// Output is json fragments that can be parsed by the ci toolset

// Global var to show BOM echo's - overridden where relevant by build scripts
$ShowBOM = false;
$CutPart=false;

// Generic modules
// ---------------

module attr(name, value, raw=false) {
    if ($ShowBOM) {
        if (raw) {
            echo(str(" '",name,"':",value,", "));
        } else {
            echo(str(" '",name,"':'",value,"', "));
        }
	}
}

module attrArray(name, close=true) {
    if ($ShowBOM) echo(str(" '",name,"': ["));
	if ($children > 0) {
		children();
		if (close && $ShowBOM)
		    echo(str(" ], "));
	} else {
	    if (close && $ShowBOM)
	        echo(str(" ], "));
	}
}

module attrNumArray(name, a) {
    if ($ShowBOM) {
        echo(str(" '",name,"': ["));
        for (i=[0:len(a)-1]) {
           if (i > 0) echo(",");
           echo(str(a[i]));
        }
        echo(str("], "));
    }
}

module object(close=true) {
    if ($ShowBOM) echo(str(" { "));
	if ($children > 0) {
		children();
	}
	if (close && $ShowBOM)
	    echo(str(" }, "));
}

module end() {
	if ($ShowBOM) echo(str(" ] }, "));
}

// Specific modules
// ----------------

module assembly(file, title, call, customAttrs=false) {
	object(true) {
        attr("type","assembly");
        attr("file",file);
        attr("title",title);
        attr("call",call);
        if (customAttrs) {
            children();
        } else {
            attrArray("children", true)
                children();
        }
    }
}

module printedPart(file, title, call, customAttrs=false) {
	object(true) {
        attr("type","printed");
        attr("file",file);
        attr("title",title);
        attr("call",call);
        // turn off explosions in children
        $Explode = false;
        if (customAttrs) {
            children();
        } else {
            attrArray("children", true)
                children();
        }
    }
}

module cutPart(file, title, call, completeCall, finalStep, showComplete=false, customAttrs=false) {
	//assign($ShowStep = (showComplete ? finalStep : $ShowStep))
    $ShowStep = (showComplete ? finalStep : $ShowStep);
    object(true) {
        attr("type","cut");
        attr("file",file);
        attr("title",title);
        attr("call",call);
        attr("completeCall",completeCall);
        // turn off explosions in children
        $Explode = false;
        if (customAttrs) {
            children();
        } else {
            attrArray("children", true)
                children();
        }
    }
}

module vitamin(file, title, call, customAttrs=false) {
	object(true) {
        attr("type","vitamin");
        attr("file",file);
        attr("title",title);
        attr("call",call);
        if (customAttrs) {
            children();
        } else {
            attrArray("children", true)
                children();
        }
    }
}

// use for sub-parts of a vitamin, triggers STL generation
module part(title, call, customAttrs=false) {
	object(true) {
        attr("type","part");
        attr("title",title);
        attr("call",call);
        if (customAttrs) {
            children();
        } else {
            attrArray("children", true)
                children();
        }
    }
}

module machine(file, title, customAttrs=false) {
    object(true) {
        attr("type","machine");
        attr("file",file);
        attr("title",title);
        if (customAttrs) {
            children();
        } else {
            attrArray("children", true)
                children();
        }
    }
}

module contains() {
    attrArray("children")
        children();
}

// Control visibility and explosion of assembly steps
module step(num=1, desc="") {
    object(false);
    attr("type","step");
    attr("num",num, raw=true);
    attr("desc",desc);
    attrArray("children", false);

    if (num <= $ShowStep) {
        $Explode= (num == $ShowStep ? $Explode : false);
        $ShowStep=100;
        children();
    }

    end();
}


module view(title="view", caption="view", size=$DefaultViewSize, t=[0, 0, 0], r=[55, 0, 25], d=500) {
    object(true) {
        attr("type","view");
        attr("title",title);
        attr("caption",caption);
        attrNumArray("size",size);
        attrNumArray("translate", t);
        attrNumArray("rotate", r);
        attr("dist", d, raw=true);
        children();
    }
}


module markdown(section="introduction", markdown="") {
    object(true) {
        attr("type","markdown");
        attr("section",section);
        attr("markdown",markdown);
    }
}

module animation(title="anim",framesPerStep=10) {
    object(true) {
        attr("title",title);
        attr("type","animation");
        attr("framesPerStep", framesPerStep, raw=true);
        children();
    }
}

module debug(s="") {
    if ($ShowBOM) {
        // TODO: decide what to do here...
    } else {
        echo(s);
    }
}
