cd  ../run_8145
load rawQdot_2rev
load HT_Data_8145
T_wall(1) = Tw(j+8)-Delta(1,j+8);
Qdot(1) = mean(line1_qdot(:,j+8));

cd ../run_8150
load rawQdot_2rev
load HT_DATA_8150
T_wall(2) = Tw(j)-Delta(5,j);
Qdot(2) = mean(line1_qdot(:,j));

cd ../run_8153
load rawQdot_2rev
load HT_Data_8153
T_wall(3) = Tw(j+8)-Delta(1,j+8);
Qdot(3) = mean(line1_qdot(:,j+8));

cd ../run_8157
load rawQdot_2rev
load HT_DATA_8157
T_wall(4) = Tw(j)-Delta(5,j);
Qdot(4) = mean(line1_qdot(:,j));

cd ../run_8161
load rawQdot_2rev
load HT_DATA_8161
T_wall(5) = Tw(j+8)-Delta(1,j+8);
Qdot(5) = mean(line1_qdot(:,j+8));

cd ../run_8165
load rawQdot_2rev
load HT_DATA_8165
T_wall(6) = Tw(j)-Delta(5,j);
Qdot(6) = mean(line1_qdot(:,j));

cd ../run_8168
load rawQdot_2rev
load HT_DATA_8168
T_wall(7) = Tw(j+8)-Delta(1,j+8);
Qdot(7) = mean(line1_qdot(:,j+8));

cd ../run_8173
load rawQdot_2rev
load HT_DATA_8173
T_wall(8) = Tw(j)-Delta(5,j);
Qdot(8) = mean(line1_qdot(:,j));