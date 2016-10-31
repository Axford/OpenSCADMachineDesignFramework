module aluAngle(w,h,l,t) {
	// stands vertically at origin (l extends in z+)
	// w in x+, h in y+
	
    vitamin(
        "vitamins/aluAngle.scad", 
        str("Aluminium Angle ",w,"x",h,"x",t,"mm x ",round(l),"mm"),
        str("aluAngle(",w,",",h,",",l,",",t,")")
    ) {
        view(t=[16,14,5], r=[168, 352, 90]);
    }  
    
	color(alu_color)
		linear_extrude(l)
		union() {
			square([t,h]);
			square([w,t]);
		}
}