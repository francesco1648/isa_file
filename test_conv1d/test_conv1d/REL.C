for (z = 0; z < 30; z++) {
	for (s = 0; s < 5; s++) {
		for (fg = 0; fg < 1; fg++) {
			for (m = 0; m < 4; m++) {
				for (j = 0; j < 5; j++) {
					for (i = 0; i <4; i++) {
						R_0 = F[m][0 + i * 4][j] * A[0 + i * 4][j + s];
							R_1 = F[m][1 + i * 4][j] * A[1 + i * 4][j + s];
							R_2 = F[m][2 + i * 4][j] * A[2 + i * 4][j + s];
							R_3 = F[m][3 + i * 4][j] * A[3 + i * 4][j + s];
							ACC[i] = R_0+ R_1+ R_2+ R_3

					}
					APP = ACC[0] + ACC[1] + ACC[2] + ACC[3];
					R_OUT[m][s]= R_OUT[m][s]+APP
				}
			}
		}

	}
}