// Coupole sur demi-ellipse : x^2/a^2 + z^2/b^2 = 1

L = 22;       // longueur (profondeur)
l = 5;        // épaisseur radiale
h_base = 10.5;

// Brique de base
module brique(largeur) {
    cube([largeur, L, l], center=true);
}

// Paramètres géométriques de l'ellipse
a = 180;
b = 90;

// ------------------------------------------------------------
// Outils ellipse
// ------------------------------------------------------------
function ellipse_z(x) = b * sqrt(max(0, 1 - pow(x / a, 2)));

function dist2(p, q) =
    pow(p[0] - q[0], 2) + pow(p[1] - q[1], 2);

// Tangente locale au point x sur la demi-ellipse
function dzdx(x) =
    x <= 0 || x >= a ? 0 : -(b*b*x) / (a*a*ellipse_z(x));

// ------------------------------------------------------------
// Recherche du point suivant à distance l sur l'ellipse
// On cherche x_{i+1} < x_i tel que distance(M_i, M_{i+1}) = l
// ------------------------------------------------------------
function next_x_from_x(x0, step, iter=12, x1_init=undef) =
    let(
        z0 = ellipse_z(x0),
        slope = dzdx(x0),
        guess = is_undef(x1_init)
            ? max(0, x0 - step / sqrt(1 + pow(slope, 2)))
            : x1_init
    )
    iter == 0 ? guess :
    let(
        x1 = guess,
        z1 = ellipse_z(x1),
        d  = sqrt(dist2([x0, z0], [x1, z1])),
        err = d - step,
        eps = 0.001,
        x2 = max(0, x1 - eps),
        z2 = ellipse_z(x2),
        d2 = sqrt(dist2([x0, z0], [x2, z2])),
        deriv = (d2 - d) / (x2 - x1)
    )
    next_x_from_x(
        x0, step, iter - 1,
        max(0, min(x0, x1 - err / deriv))
    );

// ------------------------------------------------------------
// Construction des points de la demi-ellipse
// ------------------------------------------------------------
function ellipse_points(n, step, pts = [[a, 0]]) =
    len(pts) >= n ? pts :
    let(
        last = pts[len(pts) - 1],
        x0 = last[0],
        x1 = x0 <= 0 ? 0 : next_x_from_x(x0, step),
        z1 = ellipse_z(x1)
    )
    ellipse_points(n, step, concat(pts, [[x1, z1]]));

// Nombre d'anneaux estimé
function ellipse_perimeter_approx(a, b) = 2 * PI * sqrt((pow(a, 2) + pow(b, 2)) / 2);
function nb_anneaux_calc(a, b, h) = max(1, ceil((ellipse_perimeter_approx(a, b) / 2) / h));

nb_anneaux = nb_anneaux_calc(a, b, h_base);

// Points sur la demi-ellipse
pts = ellipse_points(nb_anneaux, l);

// ------------------------------------------------------------
// Fonctions d'accès aux points
// ------------------------------------------------------------
function p_ring(i) = pts[i];
function x_ring(i) = p_ring(i)[0];
function z_ring(i) = p_ring(i)[1];

// Tangente au point i
function tang_ring(i) = 
    let(
        x = x_ring(i),
        z = z_ring(i)
    )
    abs(x) < 1e-3 ? 90 :
    atan2(b*b*x, -a*a*z);


function nb_briques(i) = 
    i == 20 ? 12 :
    max(1, ceil(2 * PI * x_ring(i) / h_base));


// Répartition des briques
function start_angle_group(i) = i == 20 ? 20 : 0;
function span_angle_group(i)  = i == 20 ? 65: 360;


function largeur_brique(i) = h_base;


// ------------------------------------------------------------
// Un anneau i
// ------------------------------------------------------------
module anneau(i) {
    xx = x_ring(i);
    zz = z_ring(i);
    n = nb_briques(i);
    tang = tang_ring(i);
    larg = largeur_brique(i);

    start_a = start_angle_group(i);
    span_a  = span_angle_group(i);
    pas_a   = n > 1 ? span_a / (n - 1) : 0;

    for (k = [0 : n - 1]) {
        a0 = start_a + k * pas_a;

        x = xx * cos(a0);
        y = xx * sin(a0);

        translate([x, y, zz])
        rotate([0, 0, a0])
        rotate([0, -tang + 90, 0])
        rotate([0, 0, 90])
            brique(larg);
    }
}

// ------------------------------------------------------------
// Coupole complète
// ------------------------------------------------------------
module coupole(n_anneaux_vises = nb_anneaux) {
    nmax = min(n_anneaux_vises, nb_anneaux);
    for (i = [0 : nmax - 1]) {
        color(i % 2 == 0 ? "red" : "blue", 1)
            anneau(i);
    }
}

coupole(21);