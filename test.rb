require 'pry'

def formula(f, level = 0)
  if /(?<logic>(AND|OR|XOR|NAND))\((?<params>.*)\)/ =~ f
    puts '  ' * level + logic
    formulas = []
    while params.match(/(?:AND|OR|XOR|NAND)\([^\(\)]*\)/)
      params.gsub!(/(?:AND|OR|XOR|NAND)\(([^\(\)]*)\)/) do |match|
        puts $1
        i = formulas.length
        formulas << $1
        "$formula#{i}$"
      end
    end
    params.split(/\s*,\s*/).each do |param|
      if /\$formula(?<i>[0-9]+)\$/ =~ param
        formula(formulas[i.to_i], level + 1)
      else
        formula(param, level + 1)
      end
    end
  elsif /\s*(?<ope>!=|==)\s*/ =~ f
    puts '  ' * level + ope
    f.gsub(/\s*/, '').split(ope.to_s).each do |param|
      puts '  ' * (level + 1) + param
    end
  end
end
f = 'OR(AND(AAA==BBB, AND(CCC == DDD, GGG!=HHH)), AND(EEE!=FFF, HHH==III))'
formula(f)
