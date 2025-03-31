#[compute]
#version 450

// Invocations in the (x, y, z) dimension
layout(local_size_x = 1024, local_size_y = 1, local_size_z = 1) in;

layout(binding = 0) restrict buffer Params {
	//float view_dist;
	//float protected_dist;
	//float avoid_factor;
	//float matching_factor;
	//float centering_factor;
	//float turn_factor;
	//float max_speed;
	//float min_speed;
	//float max_accel;
	float data[];
}
parameters;

layout(binding = 1) restrict buffer GlobalParams {
	float num_boids;
	float delta;
}
global_params;

layout(binding = 2) restrict buffer BoidsPositions {
	float data[];
}
boids_positions;

layout(binding = 3) restrict buffer BoidsVelocities {
	float data[];
}
boids_velocities;

layout(binding = 4) restrict buffer RayCastData {
	float data[];
}
raycast_data;

layout(binding = 5) restrict buffer Output {
	float data[];
}
outputs;

layout(binding = 6) restrict buffer BoidsRotations {
    float data[];
} 
rotations;

float angle_difference(float src, float dst) { return mod(dst - src + 3.1415, 2 * 3.1415) - 3.1415; }

float better_angle_lerp(float a, float b, float decay, float delta) {
    decay = decay * 25.0;
    return b + (angle_difference(b, a)) * exp(-decay * delta);
}

// The code we want to execute in each invocation
void main() {
	// gl_GlobalInvocationID.x uniquely identifies this invocation across all work groups
	int id = int(gl_GlobalInvocationID.x);

	if (id > global_params.num_boids) { return; }

	// Get the parameters for this specific boid.
	float view_dist        = parameters.data[id * 9 + 0];
	float protected_dist   = parameters.data[id * 9 + 1];
	float avoid_factor     = parameters.data[id * 9 + 2];
	float matching_factor  = parameters.data[id * 9 + 3];
	float centering_factor = parameters.data[id * 9 + 4];
	float turn_factor      = parameters.data[id * 9 + 5];
	float max_speed        = parameters.data[id * 9 + 6];
	float min_speed        = parameters.data[id * 9 + 7];
	float max_accel        = parameters.data[id * 9 + 8];

	// Get position and velocity of current boid based on id
	vec2 current_boid_position = vec2(boids_positions.data[id * 2], boids_positions.data[id * 2 + 1]);
	vec2 current_boid_velocity = vec2(boids_velocities.data[id * 2], boids_velocities.data[id * 2 + 1]);

	vec2 close_dir = vec2(0, 0);
	vec2 vel_avg = vec2(0, 0);
	vec2 pos_avg = vec2(0, 0);
	int neighboring_boids = 0;

	for (int boid_index = 0; boid_index < boids_positions.data.length(); boid_index++) {
		vec2 boid_position = vec2(boids_positions.data[boid_index * 2], boids_positions.data[boid_index * 2 + 1]);
		vec2 boid_velocity = vec2(boids_velocities.data[boid_index * 2], boids_velocities.data[boid_index * 2 + 1]);

		if (current_boid_position == boid_position) { continue; }
		if (distance(current_boid_position, boid_position) > view_dist) { continue; }

		vel_avg += boid_velocity;
		pos_avg += boid_position;
		neighboring_boids += 1;

        if (distance(current_boid_position, boid_position) < protected_dist) {
            close_dir += normalize(current_boid_position - boid_position) * 1.0;
        }
    }

	if (neighboring_boids > 0) {
		vel_avg /= neighboring_boids;
		pos_avg /= neighboring_boids;
	}

	vec2 velocity_addon = vec2(0, 0);
	float has_collider = raycast_data.data[id * 3];

	velocity_addon += close_dir * avoid_factor * global_params.delta * 60.0;
	velocity_addon += (vel_avg - current_boid_velocity) * matching_factor * global_params.delta * 60.0;
	velocity_addon += (pos_avg - current_boid_position) * centering_factor * global_params.delta * 60.0;

	vec2 collision_normal = vec2(raycast_data.data[id * 3 + 1], raycast_data.data[id * 3 + 2]);

	if (has_collider == 1.0) {
		velocity_addon += collision_normal * turn_factor * global_params.delta * 60.0;
	}

	if (length(velocity_addon) > max_accel) {
		velocity_addon = (velocity_addon / length(velocity_addon)) * max_accel;
	}

	vec2 total_velocity = current_boid_velocity + velocity_addon;

	float speed = sqrt(pow(total_velocity.x, 2.0) + pow(total_velocity.y, 2.0));

	if (speed > max_speed) {
		total_velocity = (total_velocity / speed) * max_speed;
	}
	if (speed < min_speed) {
		total_velocity = (total_velocity / speed) * min_speed; 
	}

    outputs.data[id * 3 + 0] = mix(current_boid_velocity.x, total_velocity.x, 0.4);
    outputs.data[id * 3 + 1] = mix(current_boid_velocity.y, total_velocity.y, 0.4); 
    outputs.data[id * 3 + 2] = atan(normalize(current_boid_velocity).y, normalize(current_boid_velocity).x) - 3.1415 / 2.0;
}
