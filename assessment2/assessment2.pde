void setup(){
    size(800, 800, P3D);
}

void draw(){
    // rotate a 3d cube in space
    background(255);
    translate(width/2, height/2, 0);
    rotateX(frameCount * 0.01);
    rotateY(frameCount * 0.01);
    box(200);
}
