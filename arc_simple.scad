// Dimensions d'une brique
L = 22;   // longueur (profondeur)
l = 10.5; // largeur (épaisseur radiale)
h = 5;    // hauteur (suit l'arc)

// Paramètres de l'arc
corde = 60;           // distance entre les points d'appui de l'arc
rayon = 60;           // rayon en mm (rayon intérieur)

// Angle de l'arc en degrés
 angle = 2 * asin(corde / (2 * rayon));

module arc(angle, rayon) {
    // Conversion en radians pour les calculs internes
    angle_rad_local = angle * (PI / 180);
    
    // Longueur de l'arc au rayon donné
    longueur_arc = rayon * angle_rad_local;
    
    // Nombre de briques nécessaires
    nb_briques = ceil(longueur_arc / h);
    
    // Calcul de la longueur d'arc disponible par brique
    // On divise la longueur totale d'arc par le nombre de briques
    longueur_par_brique = longueur_arc / nb_briques;
    
    // Angle entre chaque brique (basé sur la longueur réelle par brique)
    angle_brique = (longueur_par_brique / rayon) * (180 / PI);
    
    // Angle complémentaire pour que l'arc commence à l'horizontale
    angle_complementaire = 90 - (angle / 2);
    
    // Décalage radial pour que les briques ne se chevauchent pas
    rayon_centre = rayon + l/2;
    
    for (i = [0 : nb_briques - 1]) {
        // Angle de la brique le long de l'arc (centrée sur sa position)
        angle_arc = i * angle_brique + angle_brique/2;
        
        // Angle pour le calcul de la position (angle du rayon)
        angle_rayon = angle_complementaire + angle_arc;
        
        // Position sur l'arc (au centre de la brique en épaisseur)
        x = rayon_centre * cos(angle_rayon);
        z = rayon_centre * sin(angle_rayon);
        
        // Rotation de la brique : la tangente est perpendiculaire au rayon
        rotation_y = -(angle_rayon);
        
        translate([x, 0, z])
        rotate([0, rotation_y, 0])
        cube([l, L, h], center=true);
    }
}
// Exemple d'utilisation
color("red") arc(angle, rayon);

 angle_complementaire = 90 - (angle / 2);

module prism(length, width, height)
{
    polyhedron(
        points=[
            [0,   0,   0],   // 0
            [width, 0,   height], // 1
            [width, length, height], // 2
            [0,   length, 0],   // 3
            [width, 0,   0],   // 4
            [width, length, 0]    // 5
        ],
        faces=[
            [3,2,1,0], // top sloping face (A)
            [5,4,1,2],  // vertical rectangular face (B)
            [4,5,3,0], // bottom face (C)
            [1,4,0], // rear triangular face (D)
            [5,2,3] // front triangular face (E)
        ]
    );
}


length = L;
height = l* sin(angle_complementaire);
width = l* cos(angle_complementaire);


// Position du point sur l'arc à l'angle 0 (début de l'arc)
x_start = rayon * cos(angle_complementaire);
z_start = rayon * sin(angle_complementaire);

xs = x_start;
ys = -L/2; 
zs =  z_start;
 
translate([xs, ys, zs])
color("yellow") prism(length, width, height);

rotate([0, 0, 180])
translate([xs, ys, zs])
color("yellow") prism(length, width, height);

module cube_assise(longueur,largeur,hauteur){
cube([longueur,largeur,hauteur]);
  }

longueur=l;
largeur=L;
hauteur=h;
xc = xs+l;
yc = -L/2; 
zc =  zs-h; 
translate([-xc, yc, zc])
color("yellow") cube_assise(longueur,largeur,hauteur);
  
rotate([0, 0, 180])
translate([-xc, yc, zc])
color("yellow") cube_assise(longueur,largeur,hauteur);


longueur1=height;
largeur1=L;
hauteur1=l-width;
  
xb=zs+height;
yb=yc+L;
zb=xc-hauteur1;
rotate([0, 90, 0])
translate([-xb, -yb, zb])
color("yellow") cube_assise(longueur1,largeur1,hauteur1);

rotate([0, 90, 180])
translate([-xb, -yb, zb])
color("yellow") cube_assise(longueur1,largeur1,hauteur1);