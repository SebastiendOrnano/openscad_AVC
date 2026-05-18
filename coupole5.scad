// Dimensions d'une brique
L = 22;   // longueur (profondeur)
l = 5;    // largeur (épaisseur radiale)
h_base = 10.5;  // hauteur de base (suit l'arc)

// Brique de base avec largeur adjustable (CORRECTION : paramètre largeur)
module brique(largeur) {
    cube([largeur, L, l], center=true);
}

// Paramètres de l'arc (le rayon doit être égal ou supérieur à la moitié de la corde (=diamètre de la coupole)
// pour une demi-sphère, le rayon = la moitié de la corde
corde = 120;
rayon = 60;
angle = 2 * asin(corde / (2 * rayon));

// Pré-calculs du profil de la coupole
angle_rad_local = angle * PI / 180;
longueur_arc = rayon * angle_rad_local;
nb_anneaux = floor(longueur_arc / h_base);
angle_anneau = asin(h_base / (2 * rayon));
angle_complementaire = 90 - (angle / 2);
rayon_centre = rayon + l/2;

// Fonctions de position de l'anneau i
function angle_ring(i) = angle_complementaire + i * angle_anneau + angle_anneau/2;
function x_ring(i) = rayon_centre * cos(angle_ring(i));
function z_ring(i) = rayon_centre * sin(angle_ring(i));

// Rayon de la face interne de l'anneau i
function r_interne(i) = x_ring(i) ;

// Nombre de briques (ceil pour éviter les grands espaces)
function nb_briques(i) = max(1, ceil(2 * PI * r_interne(i) / h_base));

// Largeur réelle d'une brique dans l'anneau i
function largeur_brique(i) = (2 * PI * r_interne(i)) / nb_briques(i);

// Un anneau i
module anneau(i) {
    xx = x_ring(i);
    zz = z_ring(i);
    n = nb_briques(i);
    tang = angle_ring(i);
    pas_a = 360 / n;
    larg = largeur_brique(i);

    for (k = [0 : n - 1]) {
        a = k * pas_a + pas_a / 2;
        x = xx * cos(a);
        y = xx * sin(a);

        translate([x, y, zz])
        rotate([0, 0, a])
        rotate([0, -tang, 0])
        rotate([0, 0, 90])
            brique(larg);  // passe la largeur calculée
    }
}

// Coupole complète avec visualisation des anneaux en couleurs alternées
 module coupole(n_anneaux_vises = nb_anneaux) {
  nmax = min(n_anneaux_vises, nb_anneaux);
    for (i = [0 : nmax - 1]) {
      color(i % 2 == 0 ? "red" : "blue", 1) anneau(i);
}
}


  // Coupole complète avec visualisation seulement des anneaux pairs
/*
   module coupole(n_anneaux_vises = nb_anneaux) {
   nmax = min(n_anneaux_vises, nb_anneaux);
        for (i = [0 : nmax - 1]) {
            if (i % 2 == 0) color("red", 0.1) anneau(i);
       
    }
}
*/
// Exemple d'utilisation (on peut indiquer le nombre d'anneau à faire apparaitre
coupole(3);