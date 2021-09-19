#include <fstream>
#include <sstream>
#include <iostream>

int main(int argc, char **argv)
{
	std::string l;
	std::string last_kernel;
	bool saw_restype = false;
	bool saw_argtypes = false;
	
	std::ostringstream oss;
	
	// Add the extra NAIF context parameter to the function definition.
	{
		std::ifstream libspicehelper_py(argv[1]);
		while (std::getline(libspicehelper_py, l))
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
	}
	
	// Write the updated file.
	{
		std::ofstream libspicehelper_py(argv[1]);
		libspicehelper_py << oss.str();
	}
	
	oss.str("");
	
	// Add the extra NAIF context parameter to the function call.
	{
		std::ifstream spiceypy_py(argv[2]);
		while (std::getline(spiceypy_py, l))
		{
			auto pos = l.find("libspice.");
			if (pos != std::string::npos)
			{
				auto open_parenthesis = l.find("(", pos + 1);
				auto close_parenthesis = l.find(")", pos + 1);
				
				if (close_parenthesis == open_parenthesis + 1)
				{
					l.replace(open_parenthesis, 1, "(_naif_context");				
				}
				else
				{
					l.replace(open_parenthesis, 1, "(_naif_context, ");
				}
			}
			
			oss << l << std::endl;
		}
	}
	
	// Write the updated file.
	{
		std::ofstream spiceypy_py(argv[2]);
		spiceypy_py << oss.str();
	}

	return 0;
}
