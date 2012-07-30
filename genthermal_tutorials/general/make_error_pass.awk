{
	if(NR == 1){
		printf "awk -f ~u408651/bin9/sc03/2col_to_1col.awk GR%s.item | nawk -f sum_error.awk > sc03_output.item\n",$1
	}
	else{
		printf "awk -f ~u408651/bin9/sc03/2col_to_1col.awk GR%s.item | nawk -f sum_error.awk >> sc03_output.item\n",$1
	}
}
END{
	printf"# echo ''>> sc03_output.item\n"
}
