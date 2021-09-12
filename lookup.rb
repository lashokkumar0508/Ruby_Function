def get_command_line_argument
  # ARGV is an array that Ruby defines for us,
  # which contains all the arguments we passed to it
  # when invoking the script from the command line.
  # https://docs.ruby-lang.org/en/2.4.0/ARGF.html
  if ARGV.empty?
    puts "Usage: ruby lookup.rb <domain>"
    exit
  end
  ARGV.first
end

# `domain` contains the domain name we have to look up.
domain = get_command_line_argument

# File.readlines reads a file and returns an
# array of string, where each element is a line
# https://www.rubydoc.info/stdlib/core/IO:readlines
dns_raw = File.readlines("zone.txt")

def parse_dns(dns)
  dns_hash = Hash.new
  val = 0
  dns.each do |x|

    if (x[0]!="#")
      split_record = x.split(",")
      dns_clean = []
      split_record.each do |drec|
        drec = drec.strip
        dns_clean.push(drec)
      end
      dns_hash[val.to_s] = dns_clean
      val = val + 1
    end
  end
  dns_hash
end

def resolve(dnsrec, lc, dmn)
  dmnfound = false
  dnsrec.each do |key, value|
    if ((value[0] == "A") && (value[1] == dmn))
      lc.push(value[2])
      dmnfound = true
      break
    elsif(value[0] == "CNAME" && value[1] ==dmn)
      lc.push(value[2])
      resolve(dnsrec,lc,value[2])
      dmnfound = true
      break
    end

  end
  if (dmnfound == false)
    lc.push("DNS address Not found")
  end
  lc
end
# To complete the assignment, implement `parse_dns` and `resolve`.
# Remember to implement them above this line since in Ruby
# you can invoke a function only after it is defined.
dns_records = parse_dns(dns_raw)
lookup_chain = [domain]
lookup_chain = resolve(dns_records, lookup_chain, domain)
puts lookup_chain.join(" => ")
