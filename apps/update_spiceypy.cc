#include <fstream>
#include <sstream>
#include <iostream>

std::string update_libspicehelper_py(std::ifstream &fin)
{
	std::ostringstream oss;
	std::string l;
	std::string last_kernel;
	bool saw_restype = false;
	bool saw_argtypes = false;
	
	while (std::getline(fin, l))
	{
		if (l.find("libspice.") != 0)
		{
			oss << l << std::endl;
			continue;
		}
		
		// Patch...
		if (l.find("argtupes") != std::string::npos)
			l.replace(l.find("argtupes"), 8, "argtypes");
		
		std::istringstream iss(l);
			
		std::string kernel, var;
		std::getline(iss, kernel, '.');	// "libspice"
		std::getline(iss, kernel, '.');	// "[kernel]"
		std::getline(iss, var, '=');	// "[restype|argtypes]"
		
		saw_restype  = saw_restype  || var.find("restype") == 0;
		saw_argtypes = saw_argtypes || var.find("argtypes") == 0;
		
		if (var.find("argtypes") == 0)
		{
			// Update the line with the extra argument.
			if (l.find(" = [") != std::string::npos)
				l.replace(l.find(" = ["), 4, " = [c_void_p, ");
			if (l.find(" = None") != std::string::npos)
				l.replace(l.find(" = None"), 7, " = [c_void_p]");
		}

		// Copy the line to the output.
		oss << l << std::endl;

		if (kernel != last_kernel)
		{
			// Add arguments if we have none.
			if (!saw_argtypes)
			{
				oss << "libspice." << kernel << ".argtypes = [c_void_p]" << std::endl;
			}
		
			saw_restype = saw_argtypes = false;
			last_kernel = kernel;
		}
	}
	
	return oss.str();
}

std::string update_spiceypy_py(std::ifstream &fin)
{
	std::ostringstream oss;
	std::string l;
	bool in_kernels = false;
		
	while (std::getline(fin, l))
	{
		/*auto pos = l.find("libspice.");
		if (pos != std::string::npos)
		{
			auto open_parenthesis = l.find("(", pos + 1);
			auto close_parenthesis = l.find(")", pos + 1);
			
			if (close_parenthesis == open_parenthesis + 1)
			{
				l.replace(open_parenthesis, 1, "(getNaifContext()");				
			}
			else
			{
				l.replace(open_parenthesis, 1, "(getNaifContext(), ");
			}
		}*/
		
		if (l.find("def appndc") == 0)
		{
			in_kernels = true;
		}
		
		if (in_kernels && l.find("def ") == 0)
		{
			oss << "@assertNaifContext" << std::endl;
		}
		
		oss << l << std::endl;
	}
	
	return oss.str();
}

std::string update_test_wrapper_py(std::ifstream &fin)
{
	std::ostringstream oss;
	std::string l;
	
	while (std::getline(fin, l))
	{
		if (l.find("def test_") == 0)
		{
			oss << "@spice.tempNaifContext" << std::endl;
		}
		
		oss << l << std::endl;
	}
	
	return oss.str();
}

int main(int argc, char **argv)
{
	// Add the extra NAIF context parameter to the function definition.
	{
		std::ifstream fin(argv[1]);
		if (fin.good())
		{
			auto src = update_libspicehelper_py(fin);
			fin.close();
			
			std::ofstream fout(argv[1]);
			fout << src;
		}
	}
	
	// Add the extra NAIF context parameter to the function call.
	{
		std::ifstream fin(argv[2]);
		if (fin.good())
		{
			auto src = update_spiceypy_py(fin);
			fin.close();
			
			std::ofstream fout(argv[2]);
			fout << src;
		}
	}
	
	// Add the NAIF context decorator to the test functions.
	{
		std::ifstream fin(argv[3]);
		if (fin.good())
		{
			auto src = update_test_wrapper_py(fin);
			fin.close();
			
			std::ofstream fout(argv[3]);
			fout << src;
		}
	}

	return 0;
}
