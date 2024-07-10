hostname 'rename' do
  hostname 'chef-target'
end

kernel_module 'loop' do
  options [
    'max_loop=4',
    'max_part=8',
  ]
end
