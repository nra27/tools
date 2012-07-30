{
	printf "find \"%s\" ignore\n",$1
	printf "moveto $Line_Start\n"
      printf "moveto word + 2\n"
      printf "replace word with $%s\n",$1
}
