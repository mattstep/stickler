require File.expand_path( File.join( File.dirname(__FILE__), "..", "spec_helper.rb" ) )
require 'stickler/repository/index'

describe ::Stickler::Repository::Index do

  before do
    @index_me = File.join( @spec_dir, "tmp" )
    FileUtils.mkdir_p( @index_me )

    @specifications = Dir.glob( File.join( @specifications_dir, "*.gemspec" ) )
    @specifications.each do |s|
      FileUtils.cp( s, @index_me )
    end

    @index    = ::Stickler::Repository::Index.new( @index_me )
  end

  after( :each ) do
    FileUtils.rm_rf( @index_me )
  end

  it "indexes all the .gemspec files in the directory" do
    @index.specs.size.should == @specifications.size
  end

  it "is able to notice changes in the index" do
    @index.specs.size.should == @specifications.size
    FileUtils.rm( File.join( @index_me, "foo-1.0.0.gemspec" ) )
    @index.specs.size.should == ( @specifications.size - 1 )
  end

  it "knows just the latest specs" do
    @index.latest_specs.size.should == (@specifications.size - 1)
    @index.latest_specs.collect { |s| s.full_name }.sort.should == %w[ bar-1.0.0 baz-3.1.4-java foo-1.0.0 ]
  end

  it "knows the pre-release specs" do
    @index.prerelease_specs.size.should == 1
    @index.prerelease_specs.first.full_name.should == "foo-2.0.0a"
  end

  it "knows the released specs" do
    @index.released_specs.size.should == 3
    @index.released_specs.collect { |s| s.full_name }.sort.should == %w[ bar-1.0.0 baz-3.1.4-java foo-1.0.0 ]
  end
end

