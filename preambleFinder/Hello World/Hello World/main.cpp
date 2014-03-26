#include <iostream>
#include <vector>
#include <fstream>
#include <deque>
using namespace std;

int main() {

	deque <int> CircularBuffer(8) ;  //CircularBuffer is a deque of 8 characters
	deque <int> Preamble(8) ;        //Preamble is a deque of 8 characters
	int NumberPreamble = 0;              //Number of Preambles found ;
	fstream Myfile ;
	// Assign values to the Preamble deque
	Preamble.at(0) = 0 ;
	Preamble.at(1) = 1 ;
	Preamble.at(2) = 1 ;
	Preamble.at(3) = 0 ;
	Preamble.at(4) = 0 ;
	Preamble.at(5) = 1 ;
	Preamble.at(6) = 1 ;
	Preamble.at(7) = 0 ;

	//Test of Circular Buffer being equal to Preamble deque
	//CircularBuffer.at(0) = 0 ;
	//CircularBuffer.at(1) = 1 ;
	//CircularBuffer.at(2) = 1 ;
	//CircularBuffer.at(3) = 0 ;
	//CircularBuffer.at(4) = 0 ;
	//CircularBuffer.at(5) = 1 ;
	//CircularBuffer.at(6) = 1 ;
	//CircularBuffer.at(7) = 0 ;

	Myfile.open("PreambleTest.txt") ; // opens file

	// Tells the user that the file was successfully opened up
	//
	if ( Myfile.is_open() )
	{
		//when file successfully opened
		cout << "File successfully opened! " << endl ;

	//	while( !Myfile.eof() )
	//	{
	//		Myfile.get(
	//	}
	}

cout << "This is the size of the preamble: " << Preamble.size() << endl  ;

cout << "The preamble contains the following values: " ;

for ( int i = 0; i < Preamble.size(); i++)
	cout << Preamble.at(i) ;
    cout << '\n' ;

	// if the values in the circular buffer equal the values in the Preamble,
	// then the number of preambles found will increment
	if ( CircularBuffer == Preamble) 
	{
		NumberPreamble++ ;

		cout << "Number of Preambles found: " << NumberPreamble << endl ;
	}
	else 
	{
		cout << "Number of Preambles found: " << NumberPreamble << endl ;
	}



	system("pause") ;
	return 0;
}