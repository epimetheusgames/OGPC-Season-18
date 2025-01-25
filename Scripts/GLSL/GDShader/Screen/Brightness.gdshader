shader_type canvas_item;

// this is updated everytime brightness slider is changed
uniform float brightness = 0;

void fragment() {
	if(!(brightness==0.0)){
		// both of these functions were copped straight from the cpp source for the darkened()
		// and lightened() functions 
		if(brightness<0.0){
			COLOR.r = COLOR.r * (1.0 - brightness);
			COLOR.g = COLOR.g * (1.0 - brightness);
			COLOR.b = COLOR.b * (1.0 - brightness);
		}else if(brightness>0.0){
			COLOR.r = COLOR.r + (1.0 - COLOR.r) * brightness;
			COLOR.g = COLOR.r + (1.0 - COLOR.g) * brightness;
			COLOR.b = COLOR.b + (1.0 - COLOR.b) * brightness;
		}
	}else{
		COLOR = COLOR;
	}
}

