#include <algorithm>
#include <iostream>
#include <fstream>
#include <vector>
#include <stdexcept>
#include <sstream>

#define DOT			1 << 0
#define CHAR		1 << 1
#define NUM			1 << 2
#define COMMA		1 << 3
#define STAR		1 << 4
#define SEMICOLON	1 << 5
#define UNDERSCORE	1 << 6
#define OPEN_BRACE			1 << 7		/* { */
#define CLOSE_BRACE			1 << 8		/* } */
#define OPEN_BRACKET		1 << 9		/* [ */
#define CLOSE_BRACKET		1 << 10		/* ] */
#define OPEN_PARENTHESIS	1 << 11		/* ( */
#define CLOSE_PARENTHESIS	1 << 12		/* ) */
#define EXPECTED			13

const char *EXPECTED_STRINGS[] = {
	".", "CHAR", "NUM", ",", "*", ";", "_",
	"{", "}",
	"[", "]",
	"(", ")"
};

struct type_t
{
	std::string storage_class;
	std::string name;
	int indirection;
	std::string array;
	
	std::ostream &emit_prefix(std::ostream &os) const
	{
		if (storage_class.length())
		{
			std::cout << storage_class << " ";
		}

		std::cout << name << " ";			
		for (int j = 0; j < indirection; j++)
		{
			std::cout << "*";
		}
		
		return os;
	}
	
	std::ostream &emit_postfix(std::ostream &os) const
	{
		os << array;
		return os;
	}
};

struct parm_t
{
	type_t type;
	std::string name;
	bool varargs;
};
std::ostream &operator<<(std::ostream &os, const parm_t &p)
{
	p.type.emit_prefix(os);
	os << p.name;
	p.type.emit_postfix(os);
	
	return os;
};

struct method_t
{
	type_t return_type;
	std::string name;
	std::vector<parm_t> parms;
};

static const int MAX_ERRORS = 10;
static int g_error_count = 0;
static int g_current_line = 1;
static int g_current_col = 1;
static std::string g_linebuf = "";

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

char read_char(std::ifstream &fin)
{
	char c;
	
	fin.read(&c, 1);
	g_linebuf += c;
	
	if (c == '\n')
	{
		g_current_line++;
		g_linebuf = "";
		g_current_col = 0;
	}
	
	g_current_col++;
	
	return c;
}

void read_whitespace(std::ifstream &fin)
{
	while (std::isspace(fin.peek()))
	{
		read_char(fin);
	}
}

void error_occurred(const std::string &err)
{
	std::cerr << "ERROR @" << g_current_line << ":" << g_current_col << " - " << err << "." << std::endl;
	std::cerr << g_linebuf << std::endl;

	g_error_count++;
	if (g_error_count >= MAX_ERRORS)
	{
		std::cerr << MAX_ERRORS << " errors have occurred!" << std::endl;
		throw std::runtime_error("Exiting!");
	}
}

void alert_if_not_type(const std::string &s)
{
	static const std::vector<std::string> types{
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
	
	if (std::find(types.begin(), types.end(), s) == types.end())
	{
		std::ostringstream oss;
		oss << "'" << s << "' is not a valid type";
		error_occurred(oss.str());
	}
}

bool is_storage_class(const std::string &s)
{
	static const std::vector<std::string> classes{
		"auto",
		"const",
		"register"
	};
	
	return std::find(classes.begin(), classes.end(), s) != classes.end();
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
		error_occurred(oss.str());
		return;
	}
	
	for (const auto &c : s)
	{
		if (!std::isalnum(c))
		{
			std::ostringstream oss;
			oss << "'" << s << "' invalid name";
			error_occurred(oss.str());
			return;
		}
	}
}

char read_if(std::ifstream &fin, int expect, bool error)
{
	bool matched = false;
	char c = fin.peek();
	
	matched = 
		(expect & CHAR)              && std::isalpha(c) ||
		(expect & NUM)               && std::isdigit(c) ||
		(expect & DOT)               && c == '.' ||
		(expect & COMMA)             && c == ',' ||
		(expect & STAR)              && c == '*' ||
		(expect & SEMICOLON)         && c == ';' ||
		(expect & UNDERSCORE)        && c == '_' ||
		(expect & OPEN_BRACE)        && c == '{' ||
		(expect & CLOSE_BRACE)       && c == '}' ||
		(expect & OPEN_BRACKET)      && c == '[' ||
		(expect & CLOSE_BRACKET)     && c == ']' ||
		(expect & OPEN_PARENTHESIS)  && c == '(' ||
		(expect & CLOSE_PARENTHESIS) && c == ')';
		
	if (matched)
	{
		c = read_char(fin);
	}
	else if (error)
	{
		std::ostringstream oss;
		oss << "Expected ";
		for (int i = 0; i < EXPECTED; i++)
		{
			if (expect & (1 << i))
			{
				expect &= ~(1 << i);
				oss << EXPECTED_STRINGS[i];
				if (expect)
				{
					oss << "|";
				}
			}
		}
		
		oss << " but found '" << c << "'";
		
		error_occurred(oss.str());
	}
	
	return matched ? c : -1;
}

bool consume(std::ifstream &fin, int expect)
{
	return read_if(fin, expect, true) != -1;
}

std::string read_name(std::ifstream &fin)
{
	std::string s;
	char c;
	
	read_whitespace(fin);

	c = read_if(fin, CHAR | UNDERSCORE, true);
	while (c != -1)
	{
		s += c;
		
		c = fin.peek();
		if (is_grammar(c))
		{
			break;
		}
		
		c = read_if(fin, CHAR | NUM | UNDERSCORE, true);
	}

	read_whitespace(fin);

	return s;
}

type_t read_type_prefix(std::ifstream &fin)
{
	std::string s;
	type_t t;
	char c;
	
	s = read_name(fin);
	if (is_storage_class(s))
	{
		t.storage_class = s;
		t.name = read_name(fin);
	}
	else
	{
		t.storage_class = "";
		t.name = s;
	}
	
	alert_if_not_name(t.name);
	
	t.indirection = 0;
	while (fin.peek() == '*')
	{
		t.indirection++;
		read_char(fin);
		
		read_whitespace(fin);
	}
	
	return t;
}

void read_type_postfix(std::ifstream &fin, type_t &t)
{
	char c;

	read_whitespace(fin);
	
	while(read_if(fin, OPEN_BRACKET, false) != -1)
	{
		t.array += "[";

		read_whitespace(fin);
		
		while (std::isdigit(fin.peek()))
		{
			t.array += read_char(fin);
		}
		
		read_whitespace(fin);
		t.array += read_if(fin, CLOSE_BRACKET, true);
	}
}

int main(int argc, char **argv)
{
	std::ifstream fin("naif_methods.h");
	std::vector<method_t> methods;
	
	while(fin.good())
	{
		method_t m;
		char c;
		
		m.return_type = read_type_prefix(fin);
		m.name = read_name(fin);
		
		if (
			// These types have function pointers which we don't support parsing.
			m.name == "gfevnt_c" || m.name == "gffove_c" || m.name == "gfocce_c" || m.name == "gfudb_c" || m.name == "gfuds_c" || m.name == "uddc_c" || m.name == "uddf_c" ||
			
			// These have variable arguments. Can't chain them down.
			m.name == "maxd_c" || m.name == "maxi_c" || m.name == "mind_c" || m.name == "mini_c" ||
			
			// Definition exists, but implementation is missing in N066.
			m.name == "prefix_c"
		)
		{
			std::string s;
			std::getline(fin, s, ';');
			read_char(fin);
			continue;
		}
		
		consume(fin, OPEN_PARENTHESIS);
		read_whitespace(fin);
		
		if (fin.peek() == ')')
		{
			read_char(fin);
		}
		// Read all parameters.
		else while (fin.peek() != ';')
		{
			parm_t p;
			
			read_whitespace(fin);
			
			if (fin.peek() == '.')
			{
				for (int i = 0; i < 3; i++)
				{
					consume(fin, DOT);
				}
				
				p.varargs = true;
			}
			else
			{
				p.varargs = false;
				p.type = read_type_prefix(fin);
				p.name = read_name(fin);
				read_type_postfix(fin, p.type);
			}
			
			consume(fin, COMMA | CLOSE_PARENTHESIS);
			read_whitespace(fin);
			
			m.parms.push_back(p);
		}
		
		read_whitespace(fin);
		consume(fin, SEMICOLON);
		read_whitespace(fin);
		
		methods.push_back(m);
	}
	
	for (const auto &m : methods)
	{
		// Write the method prototype.
		m.return_type.emit_prefix(std::cout);
		std::cout << "NaifContext::" << m.name << "(";
		for (size_t i = 0; i < m.parms.size(); i++)
		{
			std::cout << m.parms[i];
			
			if (i != m.parms.size() - 1)
				std::cout << ", ";
		}
		std::cout << ") {";
		
		// Write the method body.
		std::cout << " return ::" << m.name << "(m_naif.get()";
		for (size_t i = 0; i < m.parms.size(); i++)
		{
			const auto &p = m.parms[i];
			
			std::cout << ", " << p.name;
		}
		std::cout << "); }" << std::endl;
	}

	return 0;
}
