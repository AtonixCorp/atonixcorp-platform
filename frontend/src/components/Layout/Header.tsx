import React, { useState } from 'react';
import {
  AppBar,
  Toolbar,
  Typography,
  Button,
  Box,
  IconButton,
  Drawer,
  List,
  ListItem,
  ListItemText,
  useTheme,
  useMediaQuery,
  Avatar,
  Menu,
  MenuItem,
  Divider,
} from '@mui/material';
import {
  Menu as MenuIcon,
  Business as BusinessIcon,
  Person,
  Logout,
  Settings,
  AccountCircle,
} from '@mui/icons-material';
import { Link, useLocation } from 'react-router-dom';
import { useAuth } from '../../contexts/AuthContext';

const Header: React.FC = () => {
  const { user, isAuthenticated, logout } = useAuth();
  const [mobileOpen, setMobileOpen] = useState(false);
  const [anchorEl, setAnchorEl] = useState<null | HTMLElement>(null);
  const theme = useTheme();
  const isMobile = useMediaQuery(theme.breakpoints.down('md'));
  const location = useLocation();

  const handleDrawerToggle = () => {
    setMobileOpen(!mobileOpen);
  };

  const handleMenu = (event: React.MouseEvent<HTMLElement>) => {
    setAnchorEl(event.currentTarget);
  };

  const handleClose = () => {
    setAnchorEl(null);
  };

  const handleLogout = () => {
    logout();
    handleClose();
  };

  const navigation = [
    { name: 'Home', path: '/' },
    { name: 'Projects', path: '/projects' },
    { name: 'Teams', path: '/teams' },
    { name: 'Focus Areas', path: '/focus-areas' },
    { name: 'Resources', path: '/resources' },
    { name: 'Community', path: '/community' },
    { name: 'Contact', path: '/contact' },
  ];

  const isActivePath = (path: string) => {
    if (path === '/') {
      return location.pathname === '/';
    }
    return location.pathname.startsWith(path);
  };

  const drawer = (
    <Box onClick={handleDrawerToggle} sx={{ textAlign: 'center' }}>
      <Typography variant="h6" sx={{ my: 2 }}>
        AtonixCorp
      </Typography>
      <List>
        {navigation.map((item) => (
          <ListItem
            key={item.name}
            component={Link}
            to={item.path}
            sx={{
              textDecoration: 'none',
              color: isActivePath(item.path) ? 'primary.main' : 'text.primary',
            }}
          >
            <ListItemText primary={item.name} />
          </ListItem>
        ))}
      </List>
    </Box>
  );

  return (
    <>
      <AppBar position="sticky" elevation={1}>
        <Toolbar>
          <Box sx={{ display: 'flex', alignItems: 'center', flexGrow: 1 }}>
            <BusinessIcon sx={{ mr: 1 }} />
            <Typography
              variant="h6"
              component={Link}
              to="/"
              sx={{
                textDecoration: 'none',
                color: 'inherit',
                fontWeight: 700,
              }}
            >
              AtonixCorp
            </Typography>
          </Box>

          {isMobile ? (
            <IconButton
              color="inherit"
              aria-label="open drawer"
              edge="start"
              onClick={handleDrawerToggle}
            >
              <MenuIcon />
            </IconButton>
          ) : (
            <Box sx={{ display: 'flex', alignItems: 'center', gap: 1 }}>
              {navigation.map((item) => (
                <Button
                  key={item.name}
                  component={Link}
                  to={item.path}
                  color="inherit"
                  sx={{
                    fontWeight: isActivePath(item.path) ? 600 : 400,
                    borderBottom: isActivePath(item.path) ? 2 : 0,
                    borderColor: 'white',
                    borderRadius: 0,
                    '&:hover': {
                      backgroundColor: 'rgba(255, 255, 255, 0.1)',
                    },
                  }}
                >
                  {item.name}
                </Button>
              ))}
              
              {/* User Authentication */}
              {isAuthenticated && user ? (
                <Box sx={{ ml: 2 }}>
                  <IconButton
                    size="large"
                    aria-label="account of current user"
                    aria-controls="menu-appbar"
                    aria-haspopup="true"
                    onClick={handleMenu}
                    color="inherit"
                  >
                    <Avatar 
                      src={user.avatar} 
                      sx={{ width: 32, height: 32 }}
                    >
                      {user.first_name[0]}
                    </Avatar>
                  </IconButton>
                  <Menu
                    id="menu-appbar"
                    anchorEl={anchorEl}
                    anchorOrigin={{
                      vertical: 'bottom',
                      horizontal: 'right',
                    }}
                    keepMounted
                    transformOrigin={{
                      vertical: 'top',
                      horizontal: 'right',
                    }}
                    open={Boolean(anchorEl)}
                    onClose={handleClose}
                  >
                    <MenuItem disabled>
                      <Typography variant="body2" fontWeight="bold">
                        {user.first_name} {user.last_name}
                      </Typography>
                    </MenuItem>
                    <MenuItem disabled>
                      <Typography variant="caption" color="text.secondary">
                        @{user.username}
                      </Typography>
                    </MenuItem>
                    <Divider />
                    <MenuItem onClick={handleClose}>
                      <AccountCircle sx={{ mr: 1 }} />
                      Profile
                    </MenuItem>
                    <MenuItem onClick={handleClose}>
                      <Settings sx={{ mr: 1 }} />
                      Settings
                    </MenuItem>
                    <Divider />
                    <MenuItem onClick={handleLogout}>
                      <Logout sx={{ mr: 1 }} />
                      Logout
                    </MenuItem>
                  </Menu>
                </Box>
              ) : (
                <Box sx={{ ml: 2 }}>
                  <Button
                    component={Link}
                    to="/community"
                    color="inherit"
                    startIcon={<Person />}
                    variant="outlined"
                    sx={{ 
                      borderColor: 'white',
                      '&:hover': {
                        borderColor: 'white',
                        backgroundColor: 'rgba(255, 255, 255, 0.1)',
                      },
                    }}
                  >
                    Sign In
                  </Button>
                </Box>
              )}
            </Box>
          )}
        </Toolbar>
      </AppBar>

      <Drawer
        variant="temporary"
        open={mobileOpen}
        onClose={handleDrawerToggle}
        ModalProps={{
          keepMounted: true, // Better open performance on mobile.
        }}
        sx={{
          display: { xs: 'block', md: 'none' },
          '& .MuiDrawer-paper': { boxSizing: 'border-box', width: 240 },
        }}
      >
        {drawer}
      </Drawer>
    </>
  );
};

export default Header;