#include <vector>
#include <iostream>
#include <fstream>
#include <sstream>

using namespace std;

void parseCSV()
{
  int count = 0;
  int non_step[10] = {0};
  std::ifstream data("test.csv");
  std::string line;
  std::vector<std::vector<std::string> > parsedCsv;
  while(std::getline(data,line))
    {
      std::stringstream lineStream(line);
      std::string cell;
      std::vector<std::string> parsedRow;
      while(std::getline(lineStream,cell,','))
	{
	  parsedRow.push_back(cell);
	  count++;
	}

      parsedCsv.push_back(parsedRow);
    }

  for(int i=0; i<=9; i++)
    {
      int start, end;
      start = end = 0;
      for(int j=0; j<count; j++)
      	{
	  if(i==stoi(parsedCsv[0][j]) && start==0)
	    start = j;
	  else if(i==stoi(parsedCsv[0][j]))
	    end = j;
	}

      //cout << "start " << start << endl << "end " << end << endl;

      for(int j=start; j<=end; j++)
	{
	  if(stoi(parsedCsv[0][j]) > i)
	    non_step[stoi(parsedCsv[0][j])]++;
	}
    }

  for(int i=0; i<=9; i++)
    cout << "non_step" << i << ": " << non_step[i] << endl;
  cout << "non_step10" << endl;
};

int main()
{
  parseCSV();
  return 0;
}
