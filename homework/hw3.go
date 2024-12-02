package main

import (
	"fmt"
)

var (
	str string = "SELECT 'Projects: %s --> %s' AS FD, " +
		"CASE WHEN COUNT(*)=0 THEN 'MAY HOLD' " +
		"ELSE 'does not hold' END AS VALIDITY " +
		"FROM (" +
		"SELECT R.%s " +
		"FROM Projects R " +
		"GROUP BY R.%s " +
		"HAVING COUNT(DISTINCT R.%s) > 1" +
		") X;"
)

func printSQL(arg1 string, arg2 string) {
	fmt.Printf(str, arg1, arg2, arg1, arg1, arg2)
	fmt.Println("")
}

func main() {
	arr := [7]string{"ID", "PID", "SID", "SN", "PN", "MID", "MN"}
	for i := 0; i < len(arr); i++ {
		for j := 0; j < len(arr); j++ {
			if i != j {
				printSQL(arr[i], arr[j])
			}
		}
	}
}
