require File.dirname(__FILE__) + '/../spec_helper'

context "Module" do
  specify "const_defined? should return false if the name is not defined" do
    Object.const_defined?("Whee").should == false
  end
  
  specify "const_defined? should return true if the name is defined" do
    class C
      class D
      end
    end

    Object.const_defined?(:Object).should == true
    C.const_defined?("D").should == true
    Object.const_defined?("C").should == true
    Object.const_defined?("Zargle").should == false
  end
  
  specify "include should accept multiple arguments" do
    class E
      include Comparable, Enumerable
    end
    E.new.class.to_s.should == 'E'
  end
  
  specify "should provide append_features" do
    module F
      def self.append_features(mod)
        super(mod)
        mod.some_class_method
      end
    end

    class G
      def self.some_class_method
        @included = true
      end
      
      def self.included?
        @included
      end
      
      include F
    end
    
    G.included?.should == true
  end
        
  specify "append_features should include self in other module unless it is already included" do
    module H; end
    module I; end
    class J
      include H, I
    end
    J.ancestors.reject { |m| m.to_s.include?(':') }.inspect.should == '[J, H, I, Object, Kernel]'
  end
end

context "Module.new method" do

  specify "should return a new instance" do
    Module.new.class.should == Module
  end

  specify "may receive a block" do
    Module.new { self }.class.should == Module
  end

end

context "Module#module_eval given a block" do
  module K
    def en
      "hello"
    end
  end

  specify "should execute on the receiver context" do
    K.module_eval { name }.should == 'K'
  end

  specify "should bind self to the receiver module" do
    (K.object_id == K.module_eval { self.object_id }).should == true
  end

end

context "Module.define_method" do
  class L
    def foo
      "ok"
    end
  end
  
  specify "should be private" do
    should_raise(NoMethodError) { L.define_method(:a) {  } }
  end

  specify "should receive an UnboundMethod" do
    L.module_eval do 
      define_method(:bar, instance_method(:foo))
    end
    L.new.bar.should == 'ok'
  end

  specify "should receive a Method" do
    L.module_eval do
      define_method(:bar, L.new.method(:foo))
    end
    L.new.bar.should == 'ok'
  end

  specify "should take a block with an argument" do
    L.module_eval do 
      define_method(:bak) { |what| "I love #{what}" }
    end
    L.new.bak("rubinius").should == "I love rubinius"
  end

  specify "should take a block with multiple arguments" do
    L.module_eval do 
      define_method(:baz) { |what, how_much| "I love #{what} #{how_much}" }
    end
    L.new.baz("rubinius", 'a whole lot').should == "I love rubinius a whole lot"
  end

  specify "should take a variadic block" do
    L.module_eval do 
      define_method(:dots) { |*args| args.join('.') }
    end
    L.new.dots(1,2,3,4,5,6).should == "1.2.3.4.5.6"
  end

  specify "should raise TypeError if not given a Proc/Method" do
    should_raise(TypeError) do
      L.module_eval do
        define_method(:bar, 1)
      end
    end
  end
  
end

context "Module" do
  module M
    def a; end
    def b; end
    def c; end
  end

  specify "should provide a method private that takes no arguments" do
    module N
      private
      def a; end
    end
    N.private_instance_methods.should == ["a"]
  end
  
  specify "should provide a method private that takes multiple arguments" do
    module M
      private :a, :b, :c
    end
    M.private_instance_methods.sort.should == ["a", "b", "c"]
  end
  
  specify "should provide a method protected that takes no arguments" do
    module O
      protected
      def a; end
    end
    O.protected_instance_methods.should == ["a"]
  end
  
  specify "should provide a method protected that takes multiple arguments" do
    module M
      protected :a, :b, :c
    end
    M.protected_instance_methods.sort.should == ["a", "b", "c"]
  end
  
  specify "should provide a method public that takes no arguments" do
    module P
      public
      def a; end
    end
    P.public_instance_methods.should == ["a"]
  end
  
  specify "should provide a method public that takes multiple arguments" do
    module M
      public :a, :b, :c
    end
    M.public_instance_methods.sort.should == ["a", "b", "c"]
  end
end
