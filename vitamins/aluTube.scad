module aluTube(od,id,l) {
    // stands vertically at origin

    vitamin(
        "vitamins/aluTube.scad",
        str("Aluminium Tube ",od,"mm OD ",id,"mm ID x ",round(l),"mm"),
        str("aluTube(",od,",",id,",",l,")")
    ) {
        view(t=[16,14,5], r=[168, 352, 90]);
    }

    color(AluColor)
        tube(od/2, id/2, l, center=false);
}
