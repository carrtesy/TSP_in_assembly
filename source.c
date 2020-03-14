#include <stdio.h>
#include <stdlib.h>
#include <math.h>

typedef struct {
	int xpos;
	int ypos;
}city;

double memory[7][256];
int parent[7][256];
double dist[7][7];	

double TSP(int cur, char visited, int previous) // previous parameter for saving parent node to memorize path for the search with the order of the path.
{	
	if (visited == (1 << 7) - 1) { // all marked. 01111111
		parent[cur][visited] = previous; 
		return dist[cur][0];//come back to city 1
	}	

	//main recursion
	//if already found distance for given path. we don't need to calculate for the same subproblem
	if (memory[cur][visited] != 0) {
		return memory[cur][visited];	
	}		
	//if not, calculate shortest path up to 
	memory[cur][visited] = 10000;	

	for (int next = 0; next < 7; next++){
		if (dist[cur][next]==0 || visited & (1 << next)) //among 7 cities, if current city has been visited already, we don't need to go there again.
			continue;
		double tmp = TSP(next, visited | (1 << next), cur) + dist[cur][next];
		if (tmp < memory[cur][visited]) {		
			parent[cur][visited] = next; //update parent node since new subproblem optimum with given city and visited state has been found.
			memory[cur][visited] = tmp;
		}	
	}
	return memory[cur][visited];	
}		

void printPath(double distance) { //search backward to find the destination of shortest path
	int start = 0;
	int idx = 0;
	int path[7];
	path[idx++] = 0;
	int pred = 1;
	char visited = 1; //already visited city 1 (00000001)
	for (int k = 0; k < 7; k++) {
		if (visited == ((1 << 7) - 1)) {//if visited all cities, end the iteration.
			break;
		}
		pred = parent[start][visited]; //parent[][] will give you the precedent city
		path[idx++] = pred;
		visited = visited | (1 << pred);
		start = pred;
	}

	printf("Destination of Shortest Path\n");
	for (int i = 0; i < sizeof(path) / sizeof(int); i++) {
		printf("[City %d] ->", path[i] + 1);
	}
	printf("[City 1] \n");
	printf("[City 1]");
	for (int i = sizeof(path)/sizeof(int)-1; i >= 0; i--) {
		printf(" ->[City %d]", path[i] + 1);
	}

}

int main() {
	city map[7];
	city c1 = { 0,0 };
	city c2 = { 8,6 }; city c3 = { 2,4 }; city c4 = { 6,7 };
	city c5 = { 1,3 }; city c6 = { 9,4 }; city c7 = { 2,3 };
	map[0] = c1;
	map[1] = c2; map[2] = c3; map[3] = c4;
	map[4] = c5; map[5] = c6; map[6] = c7;

	for (int i = 0; i < 7; i++) {
		dist[i][i] = 0.0;
		for (int j = 0; j < i; j++) {
			dist[i][j] = sqrt((double)pow(map[i].xpos - map[j].xpos, 2) + (double)pow(map[i].ypos - map[j].ypos, 2));
			dist[j][i] = dist[i][j];
		}
	}

	for (int i = 0; i < 7; i++) {//printing distance from city to city in adjacency matrix
		printf("City %d | ", i + 1);
		for (int j = 0; j < 7; j++) {
			printf("%6.3f  ", dist[i][j]);
		}
		printf("\n");
	}
	printf("\n");
	double shortestPath = TSP(0, 1, 10);
	printf("Shortest Path's Travel Distance : %.3f\n\n", shortestPath);
	printPath(shortestPath);

	printf("\n");
	system("pause");
}
