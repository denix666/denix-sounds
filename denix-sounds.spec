Name:           denix-sounds
Version:        1.0
Release:        0%{?dist}
Summary:        Desktop sounds
Group:          Other
License:        unknown
URL:            http://os.vc
Source0:        %{name}.tar.gz
BuildRoot:      %{_tmppath}/%{name}-%{version}-%{release}-root
BuildArch:      noarch

%description
Sounds for desktop

%prep
%setup -q -n %{name}

%build

%install
rm -rf %{buildroot}
cp -r %{_builddir}/%{name} %{buildroot}

%clean
rm -rf %{buildroot}
rm -rf %{_builddir}/%{name}

%files
%defattr(-,root,root,-)
%attr(0755,root,root) /usr/share/sounds/denix
%attr(0644,root,root) /usr/share/sounds/denix/*
