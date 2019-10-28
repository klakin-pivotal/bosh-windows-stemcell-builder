require 'rspec/expectations'
require './spec/packer/config/provisioner_slices/provisioner_matcher'
require './spec/packer/config/provisioner_slices/test_provisioner'

shared_examples "a standard consolidated provisioner" do |provisioner_config|
  let(:provisioners) {provisioner_config.provisioners}

  it 'uploads assets' do
    upload_assets_zip = TestProvisioner.new_file_provisioner('build/assets.zip', 'C:\provision\assets.zip')
    expect(provisioners).to include_provisioner(upload_assets_zip)
  end

  it 'run the install script' do
    install_script = TestProvisioner.new_powershell_provisioner('Install-ProvisionerScripts')
    expect(provisioners).to include_provisioner(install_script)
    # We need a way of installing our new consolidated provisioners.
    # No decision on this yet.
  end

  it 'run the first consolidated provisioner' do
    provisioner_one = TestProvisioner.new_powershell_provisioner('Run-ProvisionerOne')
    expect(provisioners).to include_provisioner(provisioner_one)
  end



end

describe 'provisioners' do
  before(:context) do
    @stemcell_deps_dir = Dir.mktmpdir('gcp')
    ENV['STEMCELL_DEPS_DIR'] = @stemcell_deps_dir
  end

  after(:context) do
    FileUtils.rm_rf(@stemcell_deps_dir)
    ENV.delete('STEMCELL_DEPS_DIR')
  end

  context 'aws' do
    standard_options = {
        aws_access_key: '',
        aws_secret_key: '',
        region: '',
        output_directory: 'some-output-directory',
        version: '',
    }

    context '1803' do
      it_behaves_like "a standard consolidated provisioner", Packer::Config::Aws.new(
          standard_options.merge(os: 'windows1803_consolidated')
      )
    end

    context '2019' do
      packer_config_aws_2019 = Packer::Config::Aws.new(
          standard_options.merge(os: 'windows2019_consolidated')
      )
      it_behaves_like "a standard consolidated provisioner", packer_config_aws_2019

    end
  end

  context 'vsphere' do
    standard_options = {
        output_directory: 'output_directory',
        num_vcpus: 1,
        mem_size: 1000,
        product_key: 'key',
        organization: 'me',
        owner: 'me',
        administrator_password: 'password',
        source_path: 'source_path',
        version: '',
        enable_rdp: false,
        new_password: 'new-password',
        http_proxy: nil,
        https_proxy: nil,
        bypass_list: nil,
    }

    context '2019' do
      packer_config_vsphere_2019 = Packer::Config::VSphere.new(
          standard_options.merge(os: 'windows2019')
      )
      it_behaves_like 'a standard consolidated provisioner', packer_config_vsphere_2019
    end
  end
end