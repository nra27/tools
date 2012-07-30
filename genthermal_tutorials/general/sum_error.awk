BEGIN{
w1=1
w2=4
w3=9
}
{
if($1 > 1000 && $1 <= 2000) {
	sume+=$2*$2*w2
	e+=1
}
else if($1 > 2000 && $1 <= 2010) {
	sumf+=$2*$2*w1
	f+=1
}
else if($1 > 2020 && $1 <= 4000) {
	sumg+=$2*$2*w3
	g+=1
}
else if($1 > 4000 && $1 <= 4010) {
	sumh+=$2*$2*w1
	h+=1
}
else if($1 > 4020 && $1 <= 6000) {
	sumj+=$2*$2*w2
	j+=1
}
}
END {
print sqrt(((sume/e)+(sumf/f)+(sumg/g)+(sumh/h)+(sumj/j))/5)
}
