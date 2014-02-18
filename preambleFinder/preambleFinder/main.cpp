////////////////////////////////////////////////////////////////////////////////////////////////
//
// Company:         USCGA
// Engineer:        1/c Jordan Keith
// Create Date:     06 Feb 2014
// Module name:     preambleFinder
// Revision:
// Additional Comments:  Takes a bitstream and looks through it to find a valid preamble.
// Once a valid preamble is found, it savves the location to an array so that user can examine
// valid preambles in given bitstream
//
////////////////////////////////////////////////////////////////////////////////////////////////

#include <iostream>
#include <fstream>
#include <stdlib.h>
#include <string>
#include <array>
using namespace std;

int main()
{
	int array_size = 10000 ;  // define the size of the character array
	char * array = new char[array_size]; // allocates an array
	int position = 0 ; // this will be used incrementally to fill characters in an array
	ifstream textfile ; 

	textfile.open("marichas_msk.txt") ;  // opens file

	// This if statement checks whether the file could be opened or not.  If file does not exit
	// or doesn't have read permisions, the file cannot be oppened
	if( textfile.is_open() )
	{
		// when file opened successfully
		cout << "File opened successfully! Reading data from file into an array" << endl ;

		//this loop will run until end of file (eof) does not occur
		while( !textfile.eof() && position < array_size )
		{
			textfile.get(array[position]);  //reading one character from file to array
			position++ ;
		}

		array[position-1] = '\0' ; //placing character array terminating character

		cout << "displaying array..." << endl << endl ;

		// creates an array of size 8
		//
		std::array<char,8> mychar;
		std::cout << "size of mychar: " << mychar.size() << std::endl ;

		//assign preamble bits 
		for ( char k = 0 ;k < 8; k++)
		{
			mychar.at(k) = 0 ;
			mychar.at(k+1) = 1 ;
			mychar.at(k+2) = 1 ;
			mychar.at(k+3) = 0 ;
			mychar.at(k+4) = 0 ;
			mychar.at(k+5) = 1 ;
			mychar.at(k+6) = 1 ;
			mychar.at(k+7) = 0 ;

			cout << "preamble is " << mychar.at(k) ;
		}



		// this loop displays all the characters in array till \0
		//
		for ( int i = 0; array[i] != '\0'; i++ )
		{
			cout << array[i] ;
		}
	}

	else //file could not be opened
	{
		cout << "file could not be opened" << endl ;
	}

	// counter for number of times a valid preamble is found
	//
	int check_ctr = 1 ;

	// cycles through all the bits

	

	textfile.close() ;
	system("pause") ;
	return(0) ;
}