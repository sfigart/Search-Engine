module DictionaryHelper
  def alpha_links(action)
    links  = []
    # Create index for 0 through 9
    (0..9).to_a.each do |number|
      links << "<span>" + link_to(number, :action => action, :alpha => number) + "</span>"
    end
    # Create index for A through Z
    ('A'..'Z').to_a.each do |letter|
      links << "<span>" + link_to(letter, :action => action, :alpha => letter) + "</span>"
    end
    raw links.join('|')
  end
end
