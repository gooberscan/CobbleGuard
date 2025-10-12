use std::collections::HashMap;
use std::fmt;

#[derive(Debug, Clone, PartialEq)]
pub enum Token<'a> {
    BroReally,
    RanTheApp,
    With,
    Bet,
    Fr,
    Was,
    Print,
    Dox,
    Swat,
    YouDroppedThis,
    Ate,
    Slay,

    String(&'a str),
    IPv4([u8; 4]),
    Integer(i64),
    Float(f64),

    Variable(&'a str),
    Identifier(&'a str),

    At,
    Colon,
    Crown,

    Eof,
}

#[derive(Debug, Clone)]
pub struct Span {
    pub line: usize,
    pub col: usize,
}

#[derive(Debug)]
pub struct ParseError {
    pub message: String,
    pub span: Span,
}

impl fmt::Display for ParseError {
    fn fmt(&self, f: &mut fmt::Formatter) -> fmt::Result {
        write!(
            f,
            "Parse error at line {}, col {}: {}",
            self.span.line, self.span.col, self.message
        )
    }
}

#[derive(Debug, Clone)]
pub enum Expr<'a> {
    Variable(&'a str),
    String(&'a str),
    IPv4([u8; 4]),
    Integer(i64),
    Float(f64),
    Dox(Box<Expr<'a>>),
    Swat(Box<Expr<'a>>),
    Array(Vec<Expr<'a>>),
}

#[derive(Debug, Clone)]
pub enum Stmt<'a> {
    Print(Expr<'a>),
    Assignment(&'a str, Expr<'a>),
    YouDroppedThis,
}

#[derive(Debug, Clone)]
pub struct Function<'a> {
    pub name: &'a str,
    pub params: Vec<&'a str>,
    pub body: Vec<Stmt<'a>>,
}

#[derive(Debug)]
pub struct Program<'a> {
    pub functions: Vec<Function<'a>>,
}

pub struct Lexer<'a> {
    input: &'a str,
    pos: usize,
    line: usize,
    col: usize,
}

impl<'a> Lexer<'a> {
    pub fn new(input: &'a str) -> Self {
        Self {
            input,
            pos: 0,
            line: 1,
            col: 1,
        }
    }

    fn current_span(&self) -> Span {
        Span {
            line: self.line,
            col: self.col,
        }
    }

    fn peek_char(&self) -> Option<char> {
        self.input[self.pos..].chars().next()
    }

    fn advance(&mut self) -> Option<char> {
        if let Some(ch) = self.peek_char() {
            self.pos += ch.len_utf8();
            if ch == '\n' {
                self.line += 1;
                self.col = 1;
            } else {
                self.col += 1;
            }
            Some(ch)
        } else {
            None
        }
    }

    fn skip_whitespace(&mut self) {
        while let Some(ch) = self.peek_char() {
            if ch.is_whitespace() {
                self.advance();
            } else {
                break;
            }
        }
    }

    fn read_while<F>(&mut self, predicate: F) -> &'a str
    where
        F: Fn(char) -> bool,
    {
        let start = self.pos;
        while let Some(ch) = self.peek_char() {
            if predicate(ch) {
                self.advance();
            } else {
                break;
            }
        }
        &self.input[start..self.pos]
    }

    fn try_keyword(&mut self, keyword: &str) -> bool {
        let remaining = &self.input[self.pos..];
        if remaining.starts_with(keyword) {
            let after = self.pos + keyword.len();
            if after >= self.input.len()
                || !self.input[after..]
                    .chars()
                    .next()
                    .unwrap()
                    .is_alphanumeric()
            {
                for _ in 0..keyword.len() {
                    self.advance();
                }
                return true;
            }
        }
        false
    }

    pub fn next_token(&mut self) -> Result<Token<'a>, ParseError> {
        self.skip_whitespace();

        let span = self.current_span();

        match self.peek_char() {
            None => Ok(Token::Eof),
            Some('@') => {
                self.advance();
                let name = self.read_while(|c| c.is_alphanumeric() || c == '_');
                if name.is_empty() {
                    Err(ParseError {
                        message: "Expected variable name after @".to_string(),
                        span,
                    })
                } else {
                    Ok(Token::Variable(name))
                }
            }
            Some(':') => {
                self.advance();
                Ok(Token::Colon)
            }
            Some('👑') => {
                self.advance();
                Ok(Token::Crown)
            }
            Some('"') => {
                self.advance();
                let start = self.pos;
                while let Some(ch) = self.peek_char() {
                    if ch == '"' {
                        let content = &self.input[start..self.pos];
                        self.advance();
                        return Ok(Token::String(content));
                    }
                    self.advance();
                }
                Err(ParseError {
                    message: "Unterminated string".to_string(),
                    span,
                })
            }
            Some(ch) if ch.is_ascii_digit() => {
                let _start = self.pos;
                let num_str = self.read_while(|c| c.is_ascii_digit() || c == '.');

                let parts: Vec<&str> = num_str.split('.').collect();
                if parts.len() == 4 {
                    let mut octets = [0u8; 4];
                    let mut is_ipv4 = true;
                    for (i, part) in parts.iter().enumerate() {
                        if let Ok(octet) = part.parse::<u8>() {
                            octets[i] = octet;
                        } else {
                            is_ipv4 = false;
                            break;
                        }
                    }
                    if is_ipv4 {
                        return Ok(Token::IPv4(octets));
                    }
                }

                if num_str.contains('.') {
                    if let Ok(f) = num_str.parse::<f64>() {
                        return Ok(Token::Float(f));
                    }
                }

                if let Ok(i) = num_str.parse::<i64>() {
                    Ok(Token::Integer(i))
                } else {
                    Err(ParseError {
                        message: format!("Invalid number: {}", num_str),
                        span,
                    })
                }
            }
            Some(_) => {
                if self.try_keyword("bro really") {
                    return Ok(Token::BroReally);
                }
                if self.try_keyword("ran the app") {
                    return Ok(Token::RanTheApp);
                }
                if self.try_keyword("you dropped this") {
                    return Ok(Token::YouDroppedThis);
                }
                if self.try_keyword("with") {
                    return Ok(Token::With);
                }
                if self.try_keyword("slay") {
                    return Ok(Token::Slay);
                }
                if self.try_keyword("ate") {
                    return Ok(Token::Ate);
                }
                if self.try_keyword("bet") {
                    return Ok(Token::Bet);
                }
                if self.try_keyword("print") {
                    return Ok(Token::Print);
                }
                if self.try_keyword("was") {
                    return Ok(Token::Was);
                }
                if self.try_keyword("dox") {
                    return Ok(Token::Dox);
                }
                if self.try_keyword("swat") {
                    return Ok(Token::Swat);
                }
                if self.try_keyword("fr") {
                    return Ok(Token::Fr);
                }

                let ident = self.read_while(|c| c.is_alphanumeric() || c == '_');
                if ident.is_empty() {
                    Err(ParseError {
                        message: format!("Unexpected character: {}", self.peek_char().unwrap()),
                        span,
                    })
                } else {
                    Ok(Token::Identifier(ident))
                }
            }
        }
    }
}

pub struct Parser<'a> {
    lexer: Lexer<'a>,
    current: Token<'a>,
}

impl<'a> Parser<'a> {
    pub fn new(input: &'a str) -> Result<Self, ParseError> {
        let mut lexer = Lexer::new(input);
        let current = lexer.next_token()?;
        Ok(Self { lexer, current })
    }

    fn advance(&mut self) -> Result<(), ParseError> {
        self.current = self.lexer.next_token()?;
        Ok(())
    }

    fn expect(&mut self, expected: Token<'a>) -> Result<(), ParseError> {
        if std::mem::discriminant(&self.current) == std::mem::discriminant(&expected) {
            self.advance()
        } else {
            Err(ParseError {
                message: format!("Expected {:?}, got {:?}", expected, self.current),
                span: self.lexer.current_span(),
            })
        }
    }

    fn parse_expr(&mut self) -> Result<Expr<'a>, ParseError> {
        match &self.current {
            Token::BroReally => {
                self.advance()?;
                self.expect(Token::Ate)?;

                let mut elements = Vec::new();
                loop {
                    match &self.current {
                        Token::Slay => {
                            self.advance()?;
                            break;
                        }
                        _ => {
                            elements.push(self.parse_primary_expr()?);
                        }
                    }
                }
                Ok(Expr::Array(elements))
            }
            _ => self.parse_primary_expr(),
        }
    }

    fn parse_primary_expr(&mut self) -> Result<Expr<'a>, ParseError> {
        match &self.current {
            Token::Variable(name) => {
                let var = *name;
                self.advance()?;
                Ok(Expr::Variable(var))
            }
            Token::String(s) => {
                let string = *s;
                self.advance()?;
                Ok(Expr::String(string))
            }
            Token::IPv4(octets) => {
                let ip = *octets;
                self.advance()?;
                Ok(Expr::IPv4(ip))
            }
            Token::Integer(i) => {
                let int = *i;
                self.advance()?;
                Ok(Expr::Integer(int))
            }
            Token::Float(f) => {
                let float = *f;
                self.advance()?;
                Ok(Expr::Float(float))
            }
            Token::Dox => {
                self.advance()?;
                let expr = self.parse_expr()?;
                Ok(Expr::Dox(Box::new(expr)))
            }
            Token::Swat => {
                self.advance()?;
                let expr = self.parse_expr()?;
                Ok(Expr::Swat(Box::new(expr)))
            }
            _ => Err(ParseError {
                message: format!("Expected expression, got {:?}", self.current),
                span: self.lexer.current_span(),
            }),
        }
    }

    fn parse_stmt(&mut self) -> Result<Option<Stmt<'a>>, ParseError> {
        match &self.current {
            Token::Print => {
                self.advance()?;
                let expr = self.parse_expr()?;
                self.expect(Token::Fr)?;
                Ok(Some(Stmt::Print(expr)))
            }
            Token::Variable(name) => {
                let var_name = *name;
                self.advance()?;
                self.expect(Token::Was)?;
                let expr = self.parse_expr()?;
                self.expect(Token::Fr)?;
                Ok(Some(Stmt::Assignment(var_name, expr)))
            }
            Token::YouDroppedThis => {
                self.advance()?;
                self.expect(Token::Colon)?;
                self.expect(Token::Crown)?;
                Ok(Some(Stmt::YouDroppedThis))
            }
            Token::Fr => Ok(None),
            _ => Err(ParseError {
                message: format!("Expected statement, got {:?}", self.current),
                span: self.lexer.current_span(),
            }),
        }
    }

    fn parse_function(&mut self) -> Result<Function<'a>, ParseError> {
        self.expect(Token::BroReally)?;

        let name = match &self.current {
            Token::RanTheApp => {
                self.advance()?;
                "main"
            }
            Token::Identifier(id) => {
                let name = *id;
                self.advance()?;
                name
            }
            _ => {
                return Err(ParseError {
                    message: "Expected function name".to_string(),
                    span: self.lexer.current_span(),
                })
            }
        };

        let mut params = Vec::new();
        if let Token::With = &self.current {
            self.advance()?;
            while let Token::Variable(param) = &self.current {
                params.push(*param);
                self.advance()?;
            }
        }

        self.expect(Token::Bet)?;

        let mut body = Vec::new();
        loop {
            match &self.current {
                Token::Fr => {
                    self.advance()?;
                    break;
                }
                Token::Eof => break,
                _ => {
                    if let Some(stmt) = self.parse_stmt()? {
                        body.push(stmt);
                    }
                }
            }
        }

        Ok(Function { name, params, body })
    }

    pub fn parse_program(&mut self) -> Result<Program<'a>, ParseError> {
        let mut functions = Vec::new();

        while self.current != Token::Eof {
            functions.push(self.parse_function()?);
        }

        Ok(Program { functions })
    }
}

pub fn parse(input: &'_ str) -> Result<Program<'_>, ParseError> {
    let mut parser = Parser::new(input)?;
    parser.parse_program()
}

#[derive(Debug, Clone, PartialEq)]
pub enum Value {
    Integer(i64),
    Float(f64),
    String(String),
    IPv4([u8; 4]),
    Array(Vec<Value>),
    Pointer(usize),
    Null,
}

impl fmt::Display for Value {
    fn fmt(&self, f: &mut fmt::Formatter) -> fmt::Result {
        match self {
            Value::Integer(i) => write!(f, "{}", i),
            Value::Float(fl) => write!(f, "{}", fl),
            Value::String(s) => write!(f, "{}", s),
            Value::IPv4(octets) => {
                write!(f, "{}.{}.{}.{}", octets[0], octets[1], octets[2], octets[3])
            }
            Value::Pointer(addr) => write!(f, "0x{:x}", addr),
            Value::Array(arr) => {
                write!(f, "[")?;
                for (i, val) in arr.iter().enumerate() {
                    write!(f, "{}", val)?;
                    if i < arr.len() - 1 {
                        write!(f, ", ")?;
                    }
                }
                write!(f, "]")
            }
            Value::Null => write!(f, "null"),
        }
    }
}

#[derive(Debug)]
pub struct RuntimeError {
    pub message: String,
}

impl fmt::Display for RuntimeError {
    fn fmt(&self, f: &mut fmt::Formatter) -> fmt::Result {
        write!(f, "Runtime error: {}", self.message)
    }
}

impl std::error::Error for RuntimeError {}

pub struct Interpreter {
    variables: HashMap<String, Value>,
    memory: Vec<Value>,
}

impl Interpreter {
    pub fn new() -> Self {
        Self {
            variables: HashMap::new(),
            memory: Vec::new(),
        }
    }

    fn eval_expr(&mut self, expr: &Expr) -> Result<Value, RuntimeError> {
        match expr {
            Expr::Variable(name) => {
                self.variables
                    .get(*name)
                    .cloned()
                    .ok_or_else(|| RuntimeError {
                        message: format!("Undefined variable: {}", name),
                    })
            }
            Expr::String(s) => Ok(Value::String(s.to_string())),
            Expr::Integer(i) => Ok(Value::Integer(*i)),
            Expr::Float(f) => Ok(Value::Float(*f)),
            Expr::IPv4(octets) => Ok(Value::IPv4(*octets)),
            Expr::Array(elements) => {
                let mut array = Vec::new();
                for element in elements {
                    array.push(self.eval_expr(element)?);
                }
                Ok(Value::Array(array))
            }
            Expr::Dox(inner) => {
                let value = self.eval_expr(inner)?;
                let addr = self.memory.len();
                self.memory.push(value);
                Ok(Value::Pointer(addr))
            }
            Expr::Swat(inner) => {
                let ptr = self.eval_expr(inner)?;
                match ptr {
                    Value::Pointer(addr) => {
                        self.memory.get(addr).cloned().ok_or_else(|| RuntimeError {
                            message: format!("Invalid memory address: {}", addr),
                        })
                    }
                    _ => Err(RuntimeError {
                        message: format!("Cannot dereference non-pointer value: {:?}", ptr),
                    }),
                }
            }
        }
    }

    fn exec_stmt(&mut self, stmt: &Stmt) -> Result<(), RuntimeError> {
        match stmt {
            Stmt::Print(expr) => {
                let value = self.eval_expr(expr)?;
                println!("{}", value);
                Ok(())
            }
            Stmt::Assignment(name, expr) => {
                let value = self.eval_expr(expr)?;
                self.variables.insert(name.to_string(), value);
                Ok(())
            }
            Stmt::YouDroppedThis => {
                println!("👑");
                Ok(())
            }
        }
    }

    fn exec_function(&mut self, func: &Function, args: Vec<Value>) -> Result<(), RuntimeError> {
        if args.len() != func.params.len() {
            return Err(RuntimeError {
                message: format!(
                    "Function {} expects {} arguments, got {}",
                    func.name,
                    func.params.len(),
                    args.len()
                ),
            });
        }

        for (param, arg) in func.params.iter().zip(args.iter()) {
            self.variables.insert(param.to_string(), arg.clone());
        }

        for stmt in &func.body {
            self.exec_stmt(stmt)?;
        }

        Ok(())
    }

    pub fn run(&mut self, program: &Program, args: Vec<Value>) -> Result<(), RuntimeError> {
        let main_func = program.functions.iter().find(|f| f.name == "main");

        match main_func {
            Some(func) => self.exec_function(func, vec![Value::Array(args)]),
            None => Err(RuntimeError {
                message: "No main function found".to_string(),
            }),
        }
    }
}

fn main() {
    let input = std::fs::read_to_string(std::env::args().nth(1).unwrap()).unwrap();
    let mut interpreter = Interpreter::new();
    let args = std::env::args()
        .skip(2)
        .map(|arg| Value::String(arg))
        .collect();

    match parse(&input) {
        Ok(program) => match interpreter.run(&program, args) {
            Ok(()) => {}
            Err(err) => eprintln!("Runtime Error: {}", err),
        },
        Err(err) => eprintln!("Error: {}", err),
    }
}
