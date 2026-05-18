// Dimensions d'une brique
L = 22;
l = 5;
h_base = 10.5;

module brique(largeur) {
    cube([largeur, L, l], center=true);
}

corde = 120;
rayon = 60;
angle = 2 * asin(corde / (2 * rayon));

angle_rad_local = angle * PI / 180;
longueur_arc = rayon * angle_rad_local;
nb_anneaux = floor(longueur_arc / h_base);
angle_anneau = asin(h_base / (2 * rayon));
angle_complementaire = 90 - (angle / 2);
rayon_centre = rayon + l/2;

function angle_ring(i) = angle_complementaire + i * angle_anneau + angle_anneau/2;
function x_ring(i) = rayon_centre * cos(angle_ring(i));
function z_ring(i) = rayon_centre * sin(angle_ring(i));
function r_interne(i) = x_ring(i);

// Nombre de briques visibles par anneau
briques_visibles = [18, 16, 5];

function nb_briques(i) =
    i == 9 ? 5 : max(1, ceil(2 * PI * r_interne(i) / h_base));

function largeur_brique(i) = h_base;

// secteur occupé par les briques du dernier anneau
function start_angle_group(i) = i == 9 ? 20 : 0;
function span_angle_group(i)  = i == 9 ? 60 : 360;

module anneau(i) {
    xx = x_ring(i);
    zz = z_ring(i);
    n = nb_briques(i);
    tang = angle_ring(i);
    larg = largeur_brique(i);

    start_a = start_angle_group(i);
    span_a  = span_angle_group(i);

    pas_a = n > 1 ? span_a / (n - 1) : 0;

    for (k = [0 : n - 1]) {
        a = start_a + k * pas_a;

        x = xx * cos(a);
        y = xx * sin(a);

        translate([x, y, zz])
        rotate([0, 0, a])
        rotate([0, -tang, 0])
        rotate([0, 0, 90])
            brique(larg);
    }
}


module coupole(n_anneaux_vises = nb_anneaux) {
    nmax = min(n_anneaux_vises, nb_anneaux);
    for (i = [0 : nmax - 1]) {
        color(i % 2 == 0 ? "red" : "blue", 1)
            anneau(i);
    }
}

coupole(10);