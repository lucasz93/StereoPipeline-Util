#include <iostream>
#include <vector>

struct type_t
{
	std::string storage_class;
	std::string name;
	int indirection;
	std::string array;
};

struct parm_t
{
	type_t type;
	std::string name;
};

struct method_t
{
	type_t return_type;
	std::string name;
	std::vector<parm_t> parms;
};

static const int MAX_ERRORS = 10;
static int g_current_line = 1;

bool is_grammar(char c)
{
	switch (c)
	{
		case '*':
		case '(':
		case ')':
		case ',':
		case ';':
		case '[':
		case ']':
			return true;
	
		default:
			break;
	}
	
	return std::isspace(c);
}

void read_whitespace(std::ifstream &fin)
{
	char c;

	while (std::isspace(fin.peek()))
	{
		fin >> c;
		
		if (c == '\n')
		{
			g_current_line++;
		}
	}
}

std::string read_word(std::ifstream &fin)
{
	std::string s;
	char c;
		
	read_whitespace(fin);
	
	while (!is_grammar(fin.peek()))
	{
		fin >> c;
		s += c;
	}
	
	read_whitespace(fin);
	
	return s;
}

void error_occurred(const std::string &err)
{
	std::cerr << "Line " << g_current_line << ": " << err << "." << std::endl;

	g_error_count++;
	if (g_error_count >= MAX_ERRORS)
	{
		std::cerr << MAX_ERRORS << " errors have occurred. Exiting!" << std::endl;
		throw std::runtime_error();
	}
}

void alert_if_not_type(const std::string &s)
{
	static const std::vector types{
		"ConstSpiceBoolean",
		"ConstSpiceChar",
		"ConstSpiceDouble",
		"ConstSpiceFloat",
		"ConstSpiceInt",
		"ConstSpicePlane",
		
		"SpiceBoolean",
		"SpiceCell",
		"SpiceChar",
		"SpiceDouble",
		"SpiceEllipse",
		"SpiceFloat",
		"SpiceInt",
		"SpiceLong",
		"ConstSpicePlane",
		"SpiceSChar",
		"SpiceShort",
		"SpiceUChar",
		"SpiceUInt",
		"SpiceULong",
		"SpiceUShort",
	};
	
	if (types.find(s) == types.end())
	{
		std::ostringstream oss;
		oss << "'" << s << "' is not a valid type";
		error_occurred(s.str());
	}
}

bool is_storage_class(const std::string &s)
{
	static const std::vector classes{
		"auto",
		"const",
		"register"
	};
	
	return classes.find(s) != classes.end();
}

void alert_if_not_name(const std::string &s)
{
	if (s == "")
	{
		error_occurred("Expected name, got empty string");
		return;
	}
	
	if (!std::isalpha(s[0]))
	{
		std::ostringstream oss;
		oss << "'" << s << "' invalid name";
		error_occurred(s.str());
		return;
	}
	
	for each (const auto &c : s)
	{
		if (!std::isalnum(c))
		{
			std::ostringstream oss;
			oss << "'" << s << "' invalid name";
			error_occurred(s.str());
			return;
		}
	}
}

std::string read_name(std::ifstream &fin)
{
	std::string s;
	char c;
	
	read_whitespace(fin);

	c = read_and_expect(fin, CHAR);
	while (std::isalnum(c))
	{
		s += c;
		
		c = fin.peek();
		if (is_grammar(c))
		{
			break;
		}
		
		c = read_and_expect(fin, CHAR | NUM);
	}
	
	read_whitespace(fin);

	return s;
}

type_t read_type_prefix(std::ifstream &fin)
{
	std::string s;
	char c;
	
	s = read_name(fin);
	if (is_storage_class(s))
	{
		type.storage_class = s;
		type.name = read_name(fin);
	}
	else
	{
		type.storage_class = "";
		type.name = s;
	}
	
	alert_if_not_name(type.name);
	
	type.indirection = 0;
	while (fin.peek() == '*')
	{
		type.indirection++;
		fin >> c;
	}
}

int main(int argc, char **argv)
{
	std::ifstream fin("naif_methods.h");
	std::string line;
	std::vector<method_t> methods;
	
	while(fin.good())
	{
		method_t m;
		
		m.return_type = read_type_prefix(fin);
		m.name = read_name(fin);
		
		// These types have function pointers which we don't support parsing.
		if (m.name == "gfevnt_c" || m.name == "gffove_c" || m.name == "gfocce_c" || m.name == "gfudb_c" || m.name == "gfuds_c" ||  m.name == "uddc_c" ||  m.name == "uddf_c")
		{
			continue;
		}
		
		expect(fin, '(');
		
		// Read all parameters.
		iss >> c;	// Skip '('.
		while (c != ')')
		{
			parm_t p;
			
			p.return_type = read_type_prefix(fin);
			m.name = read_name(fin);
			read_type_postfix(fin, p.type);

			expect(fin, ',');
			
			iss >> c;
			p.type += c;
		}
		
		read_whitespace(fin);
		expect(fin, ';');
	}
	
	for each (auto &m : methods)
	{
		std::cout >> m.return_type >> " " >> m.name >> std::endl;
	}

	return 0;
}
