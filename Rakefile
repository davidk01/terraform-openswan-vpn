require 'find'
require 'erb'
rakefile_directory = File.expand_path(File.dirname(__FILE__))

regions = {
  'production' => 'us-west-2',
  'non-production' => 'us-west-1'
}

desc 'Execute the ERB templates'
task :erb do |t, args|
  erb_files = []
  Find.find(rakefile_directory) do |path|
    if path =~ /\.erb$/
      erb_files << path
    end
  end
  erb_files.each do |input_file|
    output_file = input_file.chomp('.erb')
    input_content = File.read(input_file)
    template = ERB.new(input_content, nil, '>')
    template_result = template.result
    open(output_file, 'w') do |f|
      puts "Re-generating file: #{output_file}"
      f.write template_result
    end
  end
end

##
# Helper method for reducing some of the terraform action repetion.

def terraform_action(args, action, regions)
  environment = args[:environment]
  unless (region = regions[environment])
    raise StandardError, "Unknown environment: #{environment}"
  end
  env = "TF_VAR_region=#{region}"
  sh "cd terraform/#{environment} && env #{env} terraform #{action}"
end

[
  ["Run 'terraform plan': #{regions.keys.join('|')}", 'plan'],
  ["Run 'terraform apply' (make sure to run plan first)", 'apply'],
  ["Run 'terraform destroy'", 'destroy']
].each do |description, action|
  desc description
  task :"terraform-#{action}", [:environment] => [:erb] do |t, args|
    terraform_action(args, action, regions)
  end
end
