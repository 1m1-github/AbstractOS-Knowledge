@api function find_number_from_tmp()
    
tmp_content = strip(read("tmp", String))
path = tmp_content
file_content = strip(read(path, String))
number = parse(Int, file_content)

html = "<p>The number is $number</p>"
put!(output_devices[:MultiPathBrowserOutput], html)
end
